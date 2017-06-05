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
    public canvasBgMat as Material
    public beatTime as single
    
    private k as int = 0

    public noteSections as List of NoteSection
    public metronomeNoteSection as NoteSection

    private x as int //pos
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

    def Awake():
        noteSections = List of NoteSection()
        canvasButton.transform.localPosition = Vector2.zero 
        canvasButton.sizeDelta = Vector2(projectLength, layers)

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


    def OnScroll(eventData as PointerEventData):
        ZoomCanvas(Vector2(eventData.scrollDelta.y, 0f))


    def ZoomCanvas(direction as Vector2):
        if direction.x < 0:
            canvasButton.localScale.x *= 0.5f
        elif direction.x > 0:
            canvasButton.localScale.x *= 2f
        canvasButton.localScale.x = Mathf.Clamp(canvasButton.localScale.x, 0.05f, 2f)    
        canvasButton.GetComponent(Image).material = canvasBgMat  
        canvasBgMat.mainTextureScale.x = canvasButton.localScale.x


    def Update():
        if Input.GetKeyDown(KeyCode.LeftArrow):
            ZoomCanvas(Vector2.left)

        if Input.GetKeyDown(KeyCode.RightArrow):
            ZoomCanvas(Vector2.right)

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
        if timeIndicator.localPosition.x > 38 / canvasButton.localScale.x:
            canvasButton.localPosition.x -= 0.125f * canvasButton.localScale.x

        if recording and newNoteSection != null:
            newNoteSection.sizeDelta.x += 0.125f

        timeIndicator.localPosition.x = x * 0.125f
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
            recordedLength = currentNoteSection.GetComponent(RectTransform).sizeDelta.x * 8
            currentNoteSection.AddLength(-(currentNoteSection.sectionLength - recordedLength)/8, Vector2.right)
            currentNoteSection.resizeButtonRight.anchoredPosition.x = currentNoteSection.sectionLength / 8

        Stop()

    def Play():
        if not playing:
            playing = true
            InvokeRepeating("NextTimeStep", 0, beatTime)
            originalCanvasButtonX = canvasButton.localPosition.x
            pauseButton.SetActive(true)
            originalPosition = x
            for noteSection in noteSections:
                if noteSection.transform.localPosition.x * 8 >= originalPosition: //play from indicator
                    noteSection.Play((noteSection.transform.localPosition.x * 8)-originalPosition)
                    # print("play from indicator")
                //also play note section crossing the start point
                elif (noteSection.transform.localPosition.x * 8) + (noteSection.sectionLength * noteSection.loops) > originalPosition:
                    
                    distanceToStartPoint = originalPosition - noteSection.transform.localPosition.x * 8
                    # print("note section crossing " + (-distanceToStartPoint))
                    noteSection.Play(-distanceToStartPoint)
                    
            metronomeNoteSection.Play()
        else:
            Stop()
            

    def Pause():
        if playing:
            Stop()
            originalPosition = x
            timeIndicator.localPosition.x = x * 0.125f

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
        beatTime = 1.875f / newBPM
        print("set BPM to " + newBPM + ", beatTime: " + 1.875f / newBPM)

    public def CreateTempoMarker(x as int, newTempo as int):
        timeline.sizeDelta.x = projectLength
        # tempoMarkersMat.mainTextureScale.x = projectLength

        # newTempoMarker = Instantiate(tempoMarkerPrefab)
        # newTempoMarker.transform.SetParent(timeline, false)
        # newTempoMarker.transform.localPosition.x = x

    public def OnPointerDown(ped as PointerEventData):
        if RectTransformUtility.ScreenPointToLocalPointInRectangle(GetComponent(RectTransform), ped.position, ped.pressEventCamera, localCursorPosition) and Input.GetKey(KeyCode.LeftAlt) == false:
            localCursorPosition = Vector2(Mathf.Round(localCursorPosition.x /1) *1, Mathf.FloorToInt(localCursorPosition.y /4) *4)

        x = localCursorPosition.x * 8 / canvasButton.transform.localScale.x
        timeIndicator.localPosition.x = x * 0.125f
        cursor.localPosition = Vector3(timeIndicator.localPosition.x, localCursorPosition.y)

        DeselectAll()
        instrumentChanger.instrumentToChangeTo = null

        if lastTimeClicked + 0.2f > Time.time:
            CreateNoteSection(cursor.localPosition, 64)
        lastTimeClicked = Time.time

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
        noteSection.loopButtonRight.localPosition.x = noteSection.noteSectionRectTransform.sizeDelta.x
        noteSections.Add(noteSection)
        currentNoteSection = noteSection
        noteSection.Select()
        return noteSection.GetComponent(NoteSection)

    public def DeselectAll():
        for nS in noteSections:
            nS.Deselect()

    def DeleteSelectedNoteSections():
        if currentNoteSection != null:
            noteSections.Remove(currentNoteSection)
            Destroy(currentNoteSection.gameObject)

    def FindAvailableSpace(noteSection as NoteSection, x as int, y as int, width as int) as Vector2:
        x *= canvasButton.localScale.x
        width *= canvasButton.localScale.x

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