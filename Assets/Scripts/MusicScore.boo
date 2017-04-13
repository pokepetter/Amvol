import UnityEngine
import System.Collections
import UnityEngine.UI

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
    public tempoTapper as TempoTapper
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
    public cursor as Transform

    public instrumentChanger as InstrumentChanger
    
    private projectLength as int = 240
    private layers as int = 128
    private tempoMarkers as (int)

    private localCursorPosition as Vector2
    private lastTimeClicked as single
    private originalPosition as int
    


    def Awake():
        noteSections = List of NoteSection()
        canvasButton.transform.localPosition = Vector2.zero 

    def NewProject():
        for nS in noteSections:
            Destroy(nS.gameObject)
        noteSections.Clear()

        for i in instrumentChanger.instruments:
            Destroy(i.gameObject)
        instrumentChanger.instruments.Clear()
        instrumentChanger.Initialize()
        tempoTapper.tempo = 60

    def FixedUpdate():
        // beat time is a 32th note
        beatTime = 7.5f / tempoTapper.tempo
        // 60f / 16 / BPM


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
                Record()
            else:
                Play()

        if Input.GetKeyDown(KeyCode.Delete):
            DeleteSelectedNoteSections()

        # if Input.GetKey(KeyCode.LeftControl) and Input.GetKeyDown(KeyCode.H):
        #     if harmonyMode == false:
        #         harmonyMode = true
        #     else:
        #         harmonyMode = false

        # if Input.GetKey(KeyCode.LeftShift) and Input.GetKeyDown(KeyCode.S):
        #     Amvol.GetSaveSystem().Save(notes, "Untitled")


        if playing:
            currentTime += Time.fixedDeltaTime/beatTime
            if currentTime >= beatTime:
                currentTime = 0
                y = 0
                x++

                if recording and newNoteSection != null:
                    newNoteSection.sizeDelta.x += 0.125f

            timeIndicator.localPosition.x = x * 0.125f
            # currentTimeText.text = x.ToString()


    def Record():
        if recording == false:
            recording = true
            Play()
            //find open space for the note section
            openPosition = cursor.transform.localPosition
            for nS in noteSections:
                if (Mathf.RoundToInt(openPosition.y) == Mathf.RoundToInt(nS.transform.localPosition.y) 
                and Mathf.RoundToInt(openPosition.x) < Mathf.RoundToInt(nS.transform.localPosition.x + nS.GetComponent(RectTransform).sizeDelta.x)
                ):
                    openPosition.y += 4f

            currentNoteSection = CreateNoteSection(openPosition, 0)
            currentNoteSection.SetLength(projectLength*8)
            currentNoteSection.playing = true
            currentNoteSection.isRecording = true
            newNoteSection = currentNoteSection.transform.GetComponent(RectTransform)
            newNoteSection.sizeDelta.x = 0
            print("start recording")
            # recordButton.SetActive(true)
        else:
            recording = false
            print("stop recording")
            Play()
            currentNoteSection.playing = false
            currentNoteSection.isRecording = false
            if currentNoteSection.NumberOfNotes() == 0:
                noteSections.Remove(currentNoteSection)
                Destroy(currentNoteSection.gameObject)
                currentNoteSection = null
            else:
                //trim empty space at the end, not used in the recording
                recordedLength = currentNoteSection.GetComponent(RectTransform).sizeDelta.x * 8
                currentNoteSection.AddLength(-(currentNoteSection.sectionLength - recordedLength)/8)
                currentNoteSection.resizeButton.anchoredPosition.x = currentNoteSection.sectionLength / 8



    def Play():
        if playing == false:
            playing = true
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
            for noteSection in noteSections:
                noteSection.Stop()
            metronomeNoteSection.Stop()
            x = originalPosition
            timeIndicator.localPosition.x = x * 0.125f
            # currentTimeText.text = x.ToString()
            y = 0
            playing = false
            if recording:
                recording = false
                # print("stop recording")
                currentNoteSection.playing = false
                currentNoteSection.isRecording = false
                if currentNoteSection.NumberOfNotes() == 0:
                    Destroy(currentNoteSection.gameObject)
                    currentNoteSection = null
                # recordButton.SetActive(false)

    def Pause():
        if playing:
            originalPosition = x
            Play()

    def Stop():
        if playing:
            Play()
        x = 0
        timeIndicator.localPosition.x = 0

    public def SetBPM(newBPM as int):
        BPM = newBPM

    public def CreateTempoMarker(x as int, newTempo as int):
        timeline.sizeDelta.x = projectLength
        # tempoMarkersMat.mainTextureScale.x = projectLength

        # newTempoMarker = Instantiate(tempoMarkerPrefab)
        # newTempoMarker.transform.SetParent(timeline, false)
        # newTempoMarker.transform.localPosition.x = x

    public def OnPointerDown(ped as PointerEventData):
        i as int = 0

        if RectTransformUtility.ScreenPointToLocalPointInRectangle(GetComponent(RectTransform), ped.position, ped.pressEventCamera, localCursorPosition) and Input.GetKey(KeyCode.LeftAlt) == false:
            localCursorPosition = Vector2(Mathf.Round(localCursorPosition.x /1) *1, Mathf.FloorToInt(localCursorPosition.y /4) *4)

        cursor.localPosition = localCursorPosition
        x = localCursorPosition.x * 8 / canvasButton.transform.localScale.x
        timeIndicator.localPosition.x = x * 0.125f 

        DeselectAll()
        instrumentChanger.instrumentToChangeTo = null

        if lastTimeClicked + 0.2f > Time.time:
            CreateNoteSection(localCursorPosition, 64)
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