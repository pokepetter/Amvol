import UnityEngine
import System.Collections
import UnityEngine.UI

public class NoteSection (MonoBehaviour):

    public notePrefab as GameObject

    public playing as bool = false
    public delayLeft as int
    public currentTime as single
    # public currentNote as int
    public currentTimeText as Text

    public isRecording as bool
    public canvasButton as RectTransform
    public canvasBgMat as Material
    public bg2 as Sprite 
    
    private k as int = 0

    public notes as (single, 2)
    // a note is composed of
    // position on timeline
    // note/pitch
    // volume/power

    public x as int //pos
    private y as int //note
    private z as single //volume and short/long
    
    private input as (single)
    private scaleChanger as ScaleChanger
    private hit as RaycastHit
    public canvas as RectTransform
    public pianoRoll as RectTransform
    public timeline as RectTransform
    private currentPositionOnTimeline as int

    public instrumentChanger as InstrumentChanger
    public instrument as Instrument
    public musicScore as MusicScore
    public noteSectionRectTransform as RectTransform
    
    public sectionLength as int = 64
    public loops as single = 1f
    public loopsLeft as single
    public resizeButtonLeft as RectTransform
    public resizeButtonRight as RectTransform
    public loopButtonRight as RectTransform
    private maxNotes as int = 128
    private tempoMarkers as (int)

    public outline as Outline
    public scrollRect as ScrollRect

    public startMouse as Vector2
    public mouse as Vector2
    public deltaMouse as Vector2
    private startPosition as Vector2

    private lastTimeClicked as single
    public canvasGrid as Image
    public canvasButtonButton as Button
    public handles as GameObject
    public zoomOutButton as GameObject
    public playButton as GameObject
    public stopButton as GameObject
    
    public indicator as Transform
    private originalPosition as Vector3
    private canMoveStuff as bool = true

    def Awake():
        scaleChanger = Amvol.GetScaleChanger()
        musicScore = Amvol.GetMusicScore()
        instrumentChanger = Amvol.GetInstrumentChanger()
        UpdateInstrument(instrumentChanger.currentInstrument)
        input = array(single, maxNotes)
        transform.localScale = Vector3.zero
        DerpLerp.Scale(transform, Vector3.one, 0.2f)
        
        canvasGrid.enabled = false
        canvasButtonButton.enabled = false
        handles.SetActive(true)
        scrollRect.enabled = false

        zoomOutButton.SetActive(false)
        outline.effectDistance = Vector2.one * 0.05f
        outline.effectColor = Color.grey

    def Update():
        # if Input.GetKey(KeyCode.LeftControl) and Input.GetKeyDown(KeyCode.H):
        #     if harmonyMode == false:
        #         harmonyMode = true
        #     else:
        #         harmonyMode = false


        if startMouse != Vector2.zero and canMoveStuff:
            mouse.x = Input.mousePosition.x / Screen.width * 100
            mouse.y = Input.mousePosition.y / Screen.height * 100 /16 *9

            deltaMouse.x = Mathf.RoundToInt((mouse.x - startMouse.x) /1) *1
            deltaMouse.y = Mathf.RoundToInt((mouse.y - startMouse.y) /4) *4
            transform.localPosition = Vector2.Lerp(transform.localPosition,
                                            Vector2(Mathf.Clamp(startPosition.x + deltaMouse.x, 0, 90), 
                                                    Mathf.Clamp(startPosition.y + deltaMouse.y, 0, 44)),
                                            Time.fixedDeltaTime * 30f)


        if playing:
            currentTime += Time.fixedDeltaTime/musicScore.beatTime
            if currentTime >= musicScore.beatTime:
                currentTime = 0
                y = 0
                if delayLeft > 0:
                    delayLeft--
                else:
                    while y < maxNotes:
                        if notes[x,y] > 0f:
                            if x > 0:
                                if notes[x-1,y] == 0f:
                                    PlayNote(y, notes[x,y])
                            else:
                                PlayNote(y, notes[x,y]) 
                        if isRecording:
                            if input[y] > 0f:
                                //rounding cause lag
                                # roundedX = Mathf.RoundToInt(x/musicScore.snap) * musicScore.snap
                                # for i in range(musicScore.snap):
                                #     SetNote(roundedX + i, y, input[y])
                                SetNote(x, y, input[y])
                        if notes[x,y] == 0f and x > 0 and notes[x-1,y] > 0f:
                            StopPlayingNote(y)
                        y++
                    x++

                    if loopsLeft >= 1f:
                        if x >= sectionLength:
                            x = 0
                            y = 0
                            loopsLeft -= 1f
                            if loopsLeft <= 0f:
                                Stop()
                    else:
                        if x >= sectionLength * loopsLeft:
                            Stop()
                    


                indicator.localPosition.x = ((loops - loopsLeft) * sectionLength) + x


    def Play():
        Play(0)

    def Play(delay as int):
        if delay >= 0:
            delayLeft = delay
            loopsLeft = loops
            x = 0
        elif delay < 0:
            loopsLeft = loops - Mathf.FloorToInt(-delay/ sectionLength)
            # print(loopsLeft)
            x = -delay - ((loops-loopsLeft) * sectionLength)
            # x = -delay / (loops-loopsLeft)
        else:
            loopsLeft = loops
            x = 0
        currentPositionOnTimeline = x
        stopButton.SetActive(true)
        playButton.SetActive(false)
        playing = true

    def Stop():
        x = currentPositionOnTimeline
        y = 0

        playing = false
        stopButton.SetActive(false)
        playButton.SetActive(true)

        for i in range(128):
            StopPlayingNote(i)


    public def SetNote(x as int, y as int, z as single):
        # print("creating note"+" / "+x+" / "+y+" / "+z)
        if x >= 0 and y >= 0 and x <= sectionLength and y <= maxNotes:
            notes[x,y] = z
        else:
            print("note is out of range")

        if z > 0:
            instNote = Instantiate(notePrefab)
            instNote.transform.SetParent(canvasButton, false)
            instNote.transform.localPosition = Vector3(x, y, z)
        else:
            instNotePos = Vector3()
            for i in range(canvasButton.childCount):
                instNotePos = canvasButton.GetChild(i).transform.localPosition
                if Mathf.RoundToInt(instNotePos.x) == x and Mathf.RoundToInt(instNotePos.y) == y:
                    Destroy(canvasButton.GetChild(i).gameObject)

    public def StartNote(y as int, z as single):
        # print("start note: " + y + "/" + z)
        input[y] = z

    public def StopNote(y as int):
        tempY = 0
        tempX = 0
        for tempY in range(maxNotes):
            for tempX in range(256):
                if notes[x,y] > 0.01f:
                    nextNoteX = tempX
                    nextNoteY = tempY

        for i in range(256):
            if notes[nextNoteX+i,nextNoteY] < 0.01f:
                # print("nextNoteLength is: " + i)
                break

        # noteLengthInTime = beatTime * nextNoteLength
        # instrument.attack = 


        input[y] = 0

    public def PlayNote(y as int, z as single):
        # if harmonyMode == true:
        #     # for i in range(128):
        #     #     StopPlayingNote(i)
        #     n = scaleChanger.NoteOffset(Random.Range(y, y), false)
        #     instrumentChanger.instruments[x].PlayNote(n, z)
        #     r as int = Random.Range(0, 1)
        #     n = scaleChanger.NoteOffset(y+2 + r, false)
        #     instrumentChanger.instruments[x].PlayNote(n, z)
        #     if y > 36:
        #         r = Random.Range(0, 2)
        #         n = scaleChanger.NoteOffset(y+4 + r, false)
        #         instrumentChanger.instruments[x].PlayNote(n, z)

        # else:

        if not instrument.isDrumSet:
            y = scaleChanger.NoteOffset(y, false)
        instrument.PlayNote(y, z)        

    public def StopPlayingNote(y as int):
        if not instrument.isDrumSet:
            y = scaleChanger.NoteOffset(y, false)
        instrument.StopPlayingNote(y)

    public def UpdateInstrument(newInstrument as Instrument):
        instrument = newInstrument
        //set name
        transform.GetComponent(Image).color = instrument.instrumentColor

    public def SetLength(length as int): 
        notes = matrix(single, length, maxNotes)
        sectionLength = length
        noteSectionRectTransform.sizeDelta.x = length /8f
        canvasButton.sizeDelta.x = sectionLength
        # canvas.sizeDelta.x = length
        # canvasButton.sizeDelta = Vector2(length, maxNotes)
        # timeline.sizeDelta.x = length

        # pianoRoll.sizeDelta = Vector2(length, maxNotes)

        # canvasBgMat.mainTextureScale = Vector2(length, maxNotes)

    public def CalculateLoops():
        loops = noteSectionRectTransform.sizeDelta.x * 8 /sectionLength


    public def AddLength(length as int, direciton as Vector2):
        print("add: " + length)
        length *= 8
        canvasButton.sizeDelta.x += length

        if direciton == Vector2.right:
            if length > 0:
                newLength = notes.GetLength(0) + length
                newNotes = matrix(single, newLength, maxNotes)

                for x in range(notes.GetLength(0)):
                    for y in range(notes.GetLength(1)):
                        newNotes[x,y] = notes[x,y]
                notes = newNotes

                guiLength = newLength /8
                resizeButtonRight.anchoredPosition.x = guiLength
                if noteSectionRectTransform.sizeDelta.x < guiLength:
                    noteSectionRectTransform.sizeDelta.x = guiLength
                    loopButtonRight.localPosition.x = guiLength
            else:
                //find actual width without empty space
                x = notes.GetLength(0)-1
                while x > 0:
                    for y in range(maxNotes):
                        if notes[x,y] > 0:
                            maxX = x
                            x = 0
                            break
                    x--

                if maxX < notes.GetLength(0) + length:
                    TruncateEnd(length)
                else:
                    //TODO: show warning
                    TruncateEnd(length)
        else:
            if length > 0:
                newLength = length + notes.GetLength(0)
                newNotes = matrix(single, newLength, maxNotes)

                for x in range(length, notes.GetLength(0)):
                    for y in range(notes.GetLength(1)):
                        newNotes[x,y] = notes[x,y]
                notes = newNotes

                guiLength = newLength /8
                resizeButtonLeft.anchoredPosition.x = 0
                if noteSectionRectTransform.sizeDelta.x < guiLength:
                    noteSectionRectTransform.sizeDelta.x += guiLength
            else:
                //find actual width without empty space
                x = notes.GetLength(0)-1
                while x > 0:
                    for y in range(maxNotes):
                        if notes[x,y] > 0:
                            maxX = x
                            x = 0
                            break
                    x--

                if maxX < notes.GetLength(0) + length:
                    TruncateEnd(length)
                else:
                    //TODO: show warning
                    TruncateEnd(length)


        CalculateLoops()
        print("Added to length: " + length + ". New length is: " + notes.GetLength(0))

    def TruncateEnd(length as int):
        print("cut note section")
        sectionLength = notes.GetLength(0) + length
        newNotes = matrix(single, sectionLength, maxNotes)

        for x in range(sectionLength):
            for y in range(notes.GetLength(1)):
                newNotes[x,y] = notes[x,y]

        notes = newNotes

        for noteBox in canvasButton.GetComponentsInChildren[of RectTransform]():
            if noteBox.anchoredPosition.x > sectionLength and noteBox != indicator:
                Destroy(noteBox.gameObject)




    public def SetBPM(newBPM as int):
        BPM = newBPM

    public def CreateTempoMarker(x as int, newTempo as int):
        timeline.sizeDelta.x = sectionLength
        # tempoMarkersMat.mainTextureScale.x = sectionLength

        # newTempoMarker = Instantiate(tempoMarkerPrefab)
        # newTempoMarker.transform.SetParent(timeline, false)
        # newTempoMarker.transform.localPosition.x = x

    public def ZoomIn():
        canMoveStuff = false
        originalPosition = transform.parent.GetComponent(RectTransform).anchoredPosition
        transform.parent.GetComponent(RectTransform).anchoredPosition = Vector2(-noteSectionRectTransform.anchoredPosition.x +4, -noteSectionRectTransform.anchoredPosition.y +4)
        transform.localScale = Vector3.one * 6f
        noteSectionRectTransform.sizeDelta.y = 6f

        canvasGrid.enabled = true
        canvasButtonButton.enabled = true
        canvasButton.sizeDelta.x = sectionLength
        handles.SetActive(false)
        scrollRect.enabled = true
        
        zoomOutButton.SetActive(true)
        outline.effectDistance = Vector2.one * 0.05f
        outline.effectColor = Color.grey

    public def ZoomOut():
        canMoveStuff = true
        transform.parent.GetComponent(RectTransform).anchoredPosition = originalPosition
        transform.localScale = Vector3.one
        noteSectionRectTransform.sizeDelta.y = 3.85f

        canvasGrid.enabled = false
        canvasButtonButton.enabled = false
        handles.SetActive(true)
        scrollRect.enabled = false

        zoomOutButton.SetActive(false)
        outline.effectDistance = Vector2.one * 0.05f
        outline.effectColor = Color.grey



    public def Select():
        if Input.GetKey(KeyCode.LeftShift) == false:
            musicScore.DeselectAll()
            musicScore.currentNoteSection = self

        outline.effectDistance = Vector2.one * 0.1f
        outline.effectColor = Color.white

        if instrumentChanger.instrumentToChangeTo != null:
            UpdateInstrument(instrumentChanger.instrumentToChangeTo)

        if lastTimeClicked + 0.2f > Time.time:
            ZoomIn()
        lastTimeClicked = Time.time

    public def Deselect():
        outline.effectDistance = Vector2.zero
        # outline.effectColor = instrument.instrumentColor

    public def BeginDrag():
        # print("begin drag")
        startMouse = Vector2(Input.mousePosition.x / Screen.width * 100, Input.mousePosition.y / Screen.height * 100 /16 *9)
        startPosition = transform.localPosition

    public def EndDrag():
        desirablePosition = Vector2(Mathf.Clamp(startPosition.x + deltaMouse.x, 0, 90), Mathf.Clamp(startPosition.y + deltaMouse.y, 0, 44))
        transform.localPosition = musicScore.FindAvailableSpace(self, 
                                desirablePosition.x, 
                                desirablePosition.y, 
                                noteSectionRectTransform.sizeDelta.x)
        startMouse = Vector2.zero

    public def NumberOfNotes() as int:
        i as int = 0
        for n in notes:
            if n > 0:
                i++
        return i


    public def Quantize(snap as int):
        for y in range(maxNotes):
            for x in range(1, notes.GetLength(0), 1):
                if notes[x,y] > 0 and notes[x-1,y] == 0:
                    snapSingle as single = snap
                    closestRoundedX as int = Mathf.Round(x/snapSingle) * snapSingle
                    if closestRoundedX < x:
                        for i in range(x-closestRoundedX):
                            try:
                                SetNote(closestRoundedX+i, y, notes[x,y])
                            except:
                                print("out of range")
                    elif closestRoundedX > x:
                        for i in range(closestRoundedX-x):
                            SetNote(x+i, y, 0f)
