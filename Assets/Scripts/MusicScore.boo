import UnityEngine
import System.Collections
import UnityEngine.UI
import MidiJack


public class MusicScore (MonoBehaviour, IPointerDownHandler, IScrollHandler):

    public noteSectionPrefab as GameObject
    public currentNoteSection as NoteSection
    public newNoteSection as RectTransform
    [Space(20)]

    public playing as bool = false
    public recording as bool = false
    public recordButton as GameObject
    public currentTime as single
    public currentTimeText as Text
    public snap as int = 1
    [Space(20)]

    public canvasButton as RectTransform
    public wholeNoteGrid as Transform
    public wholeNoteGridRenderer as GridRenderer
    public beatTime as single
    public BPMIndicator as Text

    private k as int = 0

    public noteSections as List of NoteSection
    public metronomeNoteSection as NoteSection

    public x as int //pos
    private y as int //note
    private z as single //volume and short/long

    private hit as RaycastHit

    public timeline as RectTransform
    public timeIndicator as Transform
    public pauseButton as GameObject
    public recordingActiveButton as GameObject
    public cursor as Transform

    public instrumentChanger as InstrumentChanger

    private projectLength as int = 240 * 5
    private layers as int = 128
    private tempoMarkers as (int)

    private localCursorPosition as Vector2
    private lastTimeClicked as single
    private originalCanvasButtonX as single
    private originalPosition as int

    public getTempoBeforeRecording as bool
    private waitForTempoInput as bool
    private beatInputsLeft as int
    public tempoTapper as TempoTapper

    public currentZoom as int
    public previousZoom as int = 3
    private zoomLevels as ((Vector2))
    private noteSizes as (int)

    def Awake():
        noteSections = List of NoteSection()
        canvasButton.transform.localPosition = Vector2.zero
        canvasButton.sizeDelta = Vector2(projectLength, layers)

        currentZoom = 1
        zoomLevels = (
            //(main grid x, main grid y, intarnal grid x, internal grid y)
            (Vector2(0.5, 0.5), Vector2(1, 1)),      //small
            (Vector2(1, 1),     Vector2(1, 1)),      //normal
            (Vector2(2, 2),     Vector2(1, 1)),      //big

            (Vector2(1, 10),    Vector2(1, 1)),      //wholes
            (Vector2(1, 10),    Vector2(0.5, 1)),    //halves
            (Vector2(1, 10),    Vector2(0.25, 1)),   //quarters
            (Vector2(2, 10),    Vector2(0.125, 1)),  //eights
            (Vector2(4, 10),    Vector2(0.0625, 1)),  //16th
            (Vector2(8, 10),    Vector2(0.03125, 1)),  //36th
            (Vector2(16, 10),    Vector2(0.015625, 1)),  //64th
            (Vector2(32, 10),    Vector2(0.0078125, 1))   //128th
            )

        noteSizes = (0, 0, 0, 64, 32, 16, 8, 4, 2, 1)

    def Start():
        ZoomCanvas(1)

    def NewProject():
        if noteSections.Count > 0 or instrumentChanger.instruments.Count > 0:
            print("warning")
        for nS in noteSections:
            Destroy(nS.gameObject)
        noteSections.Clear()

        for i in instrumentChanger.instruments:
            Destroy(i.gameObject)
        instrumentChanger.instruments.Clear()
        instrumentChanger.Initialize()
        tempoTapper.tempo = 60
        ZoomCanvas(1)


    def OnScroll(eventData as PointerEventData):
        ZoomCanvas(currentZoom + eventData.scrollDelta.y)


    private originalCanvasPosition as Vector2

    def ZoomCanvas(newZoom as int):
        /*print("ZoomCanvas " + newZoom)*/
        if newZoom < 0:
            newZoom = 0
        elif newZoom > zoomLevels.Length:
            newZoom = zoomLevels.Length
        currentZoom = newZoom

        canvasButton.transform.localScale = zoomLevels[newZoom][0]
        if currentNoteSection != null:
            for i in range(canvasButton.childCount):
                currentNoteSection.gridParent.GetChild(i).gameObject.SetActive(false)

            if newZoom <= 2:
                currentNoteSection.canMoveStuff = true
                currentNoteSection.canvasButton.GetComponent(Button).enabled = false
                currentNoteSection.canvasButton.GetComponent(Image).enabled = false
                currentNoteSection.handles.gameObject.SetActive(true)
                currentNoteSection.loopGrid.gameObject.SetActive(true)
                currentNoteSection.scrollRect.enabled = false
                currentNoteSection.zoomOutButton.SetActive(false)
                currentNoteSection.outline.enabled = true
                NoteSizeSetter.noteSizeSetter.gameObject.SetActive(false)
                DerpLerp.MoveLocal(canvasButton.transform, originalCanvasPosition, 0.1f)
            else:
                if currentNoteSection.canMoveStuff:
                    originalCanvasPosition = canvasButton.transform.localPosition
                    /*print(originalCanvasPosition)*/
                currentNoteSection.canMoveStuff = false
                currentNoteSection.canvasButton.GetComponent(Button).enabled = true
                currentNoteSection.canvasButton.GetComponent(Image).enabled = true
                currentNoteSection.handles.gameObject.SetActive(false)
                currentNoteSection.loopGrid.gameObject.SetActive(false)
                currentNoteSection.scrollRect.enabled = true
                currentNoteSection.zoomOutButton.SetActive(true)
                currentNoteSection.outline.enabled = false
                NoteSizeSetter.noteSizeSetter.gameObject.SetActive(true)


                DerpLerp.MoveLocal(canvasButton.transform, Vector2(
                    (-currentNoteSection.transform.localPosition.x + 4) * canvasButton.transform.localScale.x,
                    (-currentNoteSection.transform.localPosition.y + .25) * canvasButton.transform.localScale.y),
                    0.1f)


                currentNoteSection.gridParent.GetChild(newZoom-3).gameObject.SetActive(true)
                NoteSizeSetter.noteSizeSetter.noteSize = noteSizes[newZoom]

        currentZoom = newZoom



    def Update():
        if Input.GetKeyDown(KeyCode.LeftArrow):
            ZoomCanvas(currentZoom-1)

        if Input.GetKeyDown(KeyCode.RightArrow):
            ZoomCanvas(currentZoom+1)

        if Input.mouseScrollDelta.y < 0:
            ZoomCanvas(currentZoom-1)
        elif Input.mouseScrollDelta.y > 0:
            ZoomCanvas(currentZoom+1)

        if Input.GetKey(KeyCode.LeftShift) and Input.GetKeyDown(KeyCode.R):
            Record()

        if Input.GetKeyDown(KeyCode.Space):
            if recording:
                StopRecording()
            else:
                Play()

        if Input.GetKeyDown(KeyCode.Delete):
            DeleteSelectedNoteSections()

        if waitForTempoInput:
            if Input.anyKeyDown:
                tempoTapper.Click()
                beatInputsLeft--
                print(beatInputsLeft)
                if beatInputsLeft <= 0:
                    tempoTapper.started = false
                    tempoTapper.ApplyTempo()
                    getTempoBeforeRecording = false
                    waitForTempoInput = false
                    Record()

            while k < 128:
                if MidiMaster.GetKeyDown(k):
                    beatInputsLeft--
                    print(beatInputsLeft)
                    if beatInputsLeft <= 0:
                        getTempoBeforeRecording = false
                        waitForTempoInput = false
                        Record()
                    break
                k++
            if k >= 128:
                k = 0

    def NextTimeStep():
        x++
        if timeIndicator.localPosition.x > 40 / canvasButton.localScale.x:
            canvasButton.localPosition.x -= 0.0625f * canvasButton.localScale.x

        if recording and newNoteSection != null:
            newNoteSection.sizeDelta.x += 0.0625f

        timeIndicator.localPosition.x = x * 0.0625f //divide by two five times
        # currentTimeText.text = x.ToString()

    def Record(newGetTempoBeforeRecording as bool):
        getTempoBeforeRecording = newGetTempoBeforeRecording
        Record()


    def ToggleRecord():
        if not recording:
            Record()
        else:
            StopRecording()

    def Record():
        if getTempoBeforeRecording:
            beatInputsLeft = 5
            waitForTempoInput = true
        else:
            recording = true
            recordingActiveButton.SetActive(true)
            //find open space for the note section
            openPosition = cursor.transform.localPosition
            for nS in noteSections:
                if (Mathf.RoundToInt(openPosition.y) == Mathf.RoundToInt(nS.transform.localPosition.y)
                and Mathf.RoundToInt(openPosition.x) < Mathf.RoundToInt(nS.transform.localPosition.x + nS.GetComponent(RectTransform).sizeDelta.x)
                ):
                    openPosition.y += 4f

            currentNoteSection = CreateNoteSection(openPosition, 0)
            currentNoteSection.SetLength(projectLength*8)
            # currentNoteSection.Play()
            currentNoteSection.isRecording = true
            newNoteSection = currentNoteSection.transform.GetComponent(RectTransform)
            newNoteSection.sizeDelta.x = 0
            Play()

    def StopRecording():
        recordingActiveButton.SetActive(false)
        currentNoteSection.Stop()
        currentNoteSection.isRecording = false
        if currentNoteSection.NumberOfNotes() > 0:
            //trim empty space at the end, not used in the recording
            currentRect = currentNoteSection.GetComponent(RectTransform)
            currentRect.sizeDelta.x = Mathf.CeilToInt(currentRect.sizeDelta.x)
            recordedLength = currentNoteSection.GetComponent(RectTransform).sizeDelta.x * 16
            currentNoteSection.AddLength(-(currentNoteSection.sectionLength - recordedLength), Vector2.right)
            currentNoteSection.automation.DrawGrid()

        Stop()

    def Play():
        if not playing:
            playing = true
            InvokeRepeating("NextTimeStep", 0, beatTime)
            originalCanvasButtonX = canvasButton.localPosition.x
            pauseButton.SetActive(true)
            originalPosition = x
            for noteSection in noteSections:
                if noteSection.transform.localPosition.x * 16 >= originalPosition: //play from indicator
                    noteSection.Play((noteSection.transform.localPosition.x * 16)-originalPosition)
                    # print("play from indicator")
                //also play note section crossing the start point
                elif (noteSection.transform.localPosition.x * 16) + (noteSection.sectionLength * noteSection.loops) > originalPosition:

                    distanceToStartPoint = originalPosition - noteSection.transform.localPosition.x * 16
                    # print("note section crossing " + (-distanceToStartPoint))
                    noteSection.Play(-distanceToStartPoint)

            metronomeNoteSection.Play()
        else:
            Stop()


    def Pause():
        if playing:
            Stop()
            originalPosition = x
            timeIndicator.localPosition.x = x * 0.0625f

    def Stop():
        CancelInvoke()
        playing = false
        x = 0
        timeIndicator.localPosition.x = 0
        recordingActiveButton.SetActive(false)

        if recording:
            recording = false
            currentNoteSection.playing = false
            currentNoteSection.isRecording = false
            if currentNoteSection.NumberOfNotes() == 0:
                noteSections.Remove(currentNoteSection)
                Destroy(currentNoteSection.gameObject)
                currentNoteSection = null

        for noteSection in noteSections:
            noteSection.Stop()
        metronomeNoteSection.Stop()
        canvasButton.localPosition.x = originalCanvasButtonX
        pauseButton.SetActive(false)
        timeIndicator.localPosition.x = x * 0.125f
        # currentTimeText.text = x.ToString()


    public def SetBPM(newBPM as int):
        beatTime = 3.75f / newBPM
        if BPMIndicator.text != beatTime.ToString():
            BPMIndicator.text = beatTime.ToString()
        print("set BPM to " + newBPM + ", beatTime: " + 3.75f / newBPM)

    public def CreateTempoMarker(x as int, newTempo as int):
        timeline.sizeDelta.x = projectLength
        # tempoMarkersMat.mainTextureScale.x = projectLength

        # newTempoMarker = Instantiate(tempoMarkerPrefab)
        # newTempoMarker.transform.SetParent(timeline, false)
        # newTempoMarker.transform.localPosition.x = x

    public def OnPointerDown(ped as PointerEventData):
        if RectTransformUtility.ScreenPointToLocalPointInRectangle(GetComponent(RectTransform), ped.position, ped.pressEventCamera, localCursorPosition) and Input.GetKey(KeyCode.LeftAlt) == false:
            localCursorPosition = Vector2(Mathf.Round(localCursorPosition.x /1) *1, Mathf.FloorToInt(localCursorPosition.y /4) *4)

        x = localCursorPosition.x * 16 / canvasButton.transform.localScale.x
        timeIndicator.localPosition.x = x * 0.0625f
        cursor.localPosition = Vector3(timeIndicator.localPosition.x, localCursorPosition.y / canvasButton.transform.localScale.y)

        DeselectAll()
        instrumentChanger.instrumentToChangeTo = null

        if lastTimeClicked + 0.2f > Time.time:
            roundedPos = Vector2(
                Mathf.FloorToInt(cursor.localPosition.x / 4) * 4,
                Mathf.FloorToInt(cursor.localPosition.y / 4) * 4)
            CreateNoteSection(roundedPos, 64)
        lastTimeClicked = Time.time


    public def PlayFromCurrentNoteSection():
        if currentNoteSection != null:
            x = currentNoteSection.transform.localPosition.x * 16 / canvasButton.transform.localScale.x
            timeIndicator.localPosition.x = x * 0.0625f
            cursor.localPosition = Vector3(timeIndicator.localPosition.x, currentNoteSection.transform.localPosition.y / canvasButton.transform.localScale.y)
            Play()

    public def PlayCurrentNoteSectionSolo():
        if currentNoteSection != null:
            if not currentNoteSection.playing:
                currentNoteSection.Play()
            else:
                currentNoteSection.Stop()


    public def CreateMetronomeNoteSection(position as Vector2, startLength as int) as NoteSection:
        metronomeNoteSection = CreateNoteSection(position, startLength)
        metronomeNoteSection.Deselect()
        noteSections.Remove(metronomeNoteSection)
        return metronomeNoteSection

    public def CreateNoteSection(position as Vector2, startLength as int) as NoteSection:
        # print("create note section, length :" + startLength)
        noteSectionObject = Instantiate(noteSectionPrefab)
        noteSectionObject.transform.SetParent(canvasButton, false)
        noteSectionObject.transform.localPosition = position
        noteSectionObject.transform.GetComponent(RectTransform).sizeDelta.x = startLength
        noteSection = noteSectionObject.GetComponent(NoteSection)
        noteSection.SetLength(startLength)
        noteSection.loopButtonRight.anchoredPosition.x = 0
        noteSections.Add(noteSection)
        currentNoteSection = noteSection
        noteSection.Select()
        noteSection.automation.DrawGrid()
        return noteSection.GetComponent(NoteSection)

    public def DeselectAll():
        for nS in noteSections:
            nS.Deselect()

    def DeleteSelectedNoteSections():
        if currentNoteSection != null:
            noteSections.Remove(currentNoteSection)
            Destroy(currentNoteSection.gameObject)

    def FindAvailableSpace(noteSection as NoteSection, x as int, y as int, width as int) as Vector2:
        # x *= canvasButton.localScale.x
        # width *= canvasButton.localScale.x

        for nS in noteSections:
            if nS != noteSection:
                //limit y
                currentRect = nS.GetComponent(RectTransform)
                if currentRect.anchoredPosition.y == y:
                    print("same line")
                    if x >= currentRect.anchoredPosition.x and x < currentRect.anchoredPosition.x + currentRect.sizeDelta.x:
                        print("space conflict")
                        x = currentRect.anchoredPosition.x + currentRect.sizeDelta.x
                        if not FindAvailableSpace(noteSection, x, y, width) == Vector2(x,y):
                            print("move note sections on line forward")
                    elif x < currentRect.anchoredPosition.x and x+width < currentRect.anchoredPosition.x + currentRect.sizeDelta.x:
                        x = currentRect.anchoredPosition.x - width

        availablePosition = Vector2(x,y)
        return availablePosition
