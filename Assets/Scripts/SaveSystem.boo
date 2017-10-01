import UnityEngine
import System.IO
import System.Collections
import UnityEngine.UI

public class SaveSystem (MonoBehaviour): 
    
    public instrumentChanger as InstrumentChanger
    public musicScore as MusicScore
    public scaleChanger as ScaleChanger
    public header as Text
    public instrumentStringParts as (string)

    private tex as Texture2D
    private rect as Rect
    private bytes as (byte)
    private data as (byte)
    private noteCache as (single)
    private pointer as int
    private returnValue as uint
    private x as int
    private y as int
    private audioClip as AudioClip


    def Awake():
        args = Environment.GetCommandLineArgs()
        for a in args:
            print(a)
        if args.Length > 0:
          try:
              Load(Environment.GetCommandLineArgs()[1])
          except:
              pass

        noteCache = array(single, 256)

    public def Save(filePath as string):
        tex = Texture2D.blackTexture
        
        //find document length
        noteSections = Amvol.GetMusicScore().noteSections
        if noteSections.Count == 0:
            print('nothing to save')
        else:
            width = 0
            for noteSection in noteSections:
                if noteSection.transform.localPosition.x * 16 + (noteSection.sectionLength * noteSection.loops) > width:
                    width = noteSection.transform.localPosition.x * 16 + (noteSection.sectionLength * noteSection.loops)

            lastNoteSection = noteSections[0]
            for noteSection in noteSections:
                if noteSection.transform.localPosition.y > lastNoteSection.transform.localPosition.y:
                    lastNoteSection = noteSection
            height = (lastNoteSection.transform.localPosition.y * 32) + 128

            tex = Texture2D(width, height+2, TextureFormat.RGB24, false) //+2 for saving other data in row 0
            for y in range(tex.height):
                for x in range(tex.width):
                    tex.SetPixel(x, y, Color.black)

        //line 0: tempo
        tex.SetPixel(0, 0, Color32(musicScore.tempoTapper.tempo, 0, 0, 0))

        //line 1: instruments volume, attack, falloff, scale
        for i in range(instrumentChanger.instruments.Count):
            inst = instrumentChanger.instruments[i]
            tex.SetPixel(i, 1, Color(inst.volume, inst.attack /100f, inst.falloff /100f))

        //scale length    
        x = instrumentChanger.instruments.Count + 1
        tex.SetPixel(x, 1, Color32(scaleChanger.scaleLength, 0, 0, 0))
        //scalePattern
        scaleAsCharArray as (char) = scaleChanger.currentScale.ToCharArray()
        scaleAsIntArray = array(int, scaleAsCharArray.Length)
        for i in range(scaleAsIntArray.Length):
            scaleAsIntArray[i] = Char.GetNumericValue(scaleAsCharArray[i])

        for j in range(scaleAsIntArray.Length):
            tex.SetPixel(x+1 + j, 1, Color32(scaleAsIntArray[j], 0, 0, 0))
        //scale offset
        tex.SetPixel(x + scaleChanger.scaleLength + 1, 1, Color32(scaleChanger.scaleOffset, 0, 0, 0))
        //note offset
        tex.SetPixel(x + scaleChanger.scaleLength + 2, 1, Color32(scaleChanger.noteOffset, 0, 0, 0))
        

        //line 3 and up: note sections
        for noteSection in noteSections:
            x = 0
            y = 1
            posX = noteSection.transform.localPosition.x * 16

            //start section
            print("note section start: " + Vector2(posX, (noteSection.transform.localPosition.y * 32) +2))
            tex.SetPixel(posX, (noteSection.transform.localPosition.y * 32) +2, Color.green)

            //instrumentIndex
            instrumentIndex = 0
            for instrumentIndex in range(instrumentChanger.instruments.Count):
                if noteSection.instrument == instrumentChanger.instruments[instrumentIndex]:
                    break
            tex.SetPixel(posX + 1, (noteSection.transform.localPosition.y * 32) +2, Color32(instrumentIndex, 0, 0, 0))

            //whole loops
            tex.SetPixel(posX + 2, (noteSection.transform.localPosition.y * 32) +2, Color32(0, Mathf.FloorToInt(noteSection.loops), 0, 0)) //max 255 loops :/

            //partial loops
            if noteSection.loops - Mathf.FloorToInt(noteSection.loops) > 0f:
                tex.SetPixel(posX + 3, (noteSection.transform.localPosition.y * 32) +2, Color(noteSection.loops - Mathf.FloorToInt(noteSection.loops), 0, 0))

            //end section
            tex.SetPixel(((noteSection.transform.localPosition.x * 16) + noteSection.sectionLength) -1, (noteSection.transform.localPosition.y * 32) +2, Color.blue)
            
            //save notes
            for x in range(noteSection.sectionLength):
                for y in range(1, 128):
                    tex.SetPixel(x + noteSection.transform.localPosition.x * 16, (noteSection.transform.localPosition.y * 32) + y +2, Color(noteSection.notes[x,y], 0, 0))


            //save volume automation
            for i in range(noteSection.automation.lineRenderer.points.Length-1):
                point = noteSection.automation.lineRenderer.points[i]
                x = noteSection.transform.localPosition.x * 32 + (i * 16)
                y = (noteSection.transform.localPosition.y * 32) + 3 + (point.y / noteSection.noteSectionRectTransform.rect.height * 127)
                # print(y)

                pixel = tex.GetPixel(x, y)
                tex.SetPixel(x, y, pixel + Color(0, 1, 0))


        bytes = tex.EncodeToPNG()
        
        
        instrumentInfo = "Instruments: "
        for i in range(instrumentChanger.instruments.Count):
            instrument = instrumentChanger.instruments[i]
            instrumentInfo += instrument.gameObject.name
            if i < instrumentChanger.instruments.Count -1:
                instrumentInfo += ", "
        instrumentBytes = Encoding.UTF8.GetBytes(instrumentInfo)

        bytes += instrumentBytes


        print("saved to " + filePath)
        File.WriteAllBytes(filePath, bytes)

    public def Load(path as string):
        StartCoroutine(LoadRoutine(path))

    public def LoadRoutine(path as string) as IEnumerator:
        print(path)
        if File.Exists(path):
            fileData = File.ReadAllBytes(path)
            tex = Texture2D.blackTexture
            tex.LoadImage(fileData)//..this will auto-resize the texture dimensions.
            header.text = path

            musicScore.NewProject()
            instrumentChanger.ClearAllInstruments()

            instrumentString = Encoding.UTF8.GetString(fileData)
            instrumentStringParts = Regex.Split(instrumentString, "Instruments: ")
            if instrumentStringParts.Length > 1:
                instrumentString = instrumentStringParts[1]
            instrumentStringParts = Regex.Split(instrumentString, ", ")

            for i in range(instrumentStringParts.Length):
                instrument = instrumentChanger.AddInstrument()
                instrumentList = instrument.transform.GetComponent(InstrumentList)
                instrumentList.OpenList()

                for j in range(instrumentList.content.transform.childCount):
                    if instrumentStringParts[i] == instrumentList.content.transform.GetChild(j).gameObject.name:
                        # print("found instrument with name: " + instrumentList.content.transform.GetChild(j).gameObject.name)
                        instrumentList.content.transform.GetChild(j).GetComponent(InstrumentButton).SelectFile()
                        foundInstrument = true
                if foundInstrument == false:
                    print("no instrument with name: " + instrumentStringParts[i] + ", loading default")
                    instrumentList.content.transform.GetChild(0).GetComponent(InstrumentButton).SelectFile()

            instrumentChanger.SetCurrentInstrument(instrument)


            //line 0: tempo
            color as Color32 = tex.GetPixel(0,0)
            musicScore.tempoTapper.tempo = color.r

            //line 1: instruments volume, attack, falloff, scale
            for i in range(128):
                if tex.GetPixel(1+i, 1) == Color.black:
                    break
                inst = instrumentChanger.instruments[i]
                inst.volume = tex.GetPixel(1+i, 1).r
                inst.attack = tex.GetPixel(1+i, 1).g * 100f
                inst.falloff = tex.GetPixel(1+i, 1).b * 100f

            //scalePattern  
            x = instrumentChanger.instruments.Count + 1
            scalePattern as string = ""
            color = tex.GetPixel(x, 1)
            for j in range(color.r):
                color = tex.GetPixel(x+1 + j, 1)
                scalePattern += color.r.ToString()
            scaleChanger.SetScale(scalePattern)
            
            //scale offset
            color = tex.GetPixel(x + scaleChanger.scaleLength + 1, 1)
            scaleChanger.scaleOffset = color.r
            //note offset
            color = tex.GetPixel(x + scaleChanger.scaleLength + 2, 1)
            scaleChanger.noteOffset = color.r

            for h in range(2, tex.height, 128):
                for w in range(tex.width):
                    //find note section start
                    if tex.GetPixel(w,h) == Color.green:
                        print("found note section start")
                        startPosition = w
                        //find note section end
                        for x in range(startPosition, tex.width):
                            if tex.GetPixel(x,h) == Color.blue:
                                print("found note section end")
                                noteSectionLength = x - startPosition +1
                                break


                        noteSection = musicScore.CreateNoteSection(Vector2(w /16, Mathf.FloorToInt((h-2)/32)), noteSectionLength)
                        instIndex as Color32 = tex.GetPixel(w+1, h)
                        # print(instIndex.r)
                        noteSection.UpdateInstrument(instrumentChanger.instruments[instIndex.r])
                        //find number of loops
                        wholeLoops as Color32 = tex.GetPixel(startPosition+2, h)
                        noteSection.loops = wholeLoops.g
                        //partial loops
                        noteSection.loops += tex.GetPixel(startPosition+3, h).g
                        noteSection.noteSectionRectTransform.sizeDelta.x = noteSectionLength * noteSection.loops /16
                        noteSection.CalculateLoops()

                        //set notes
                        for x in range(noteSectionLength):
                            for y in range(128):
                                noteSection.SetNote(x, y, tex.GetPixel(w+x, h+y).r)

                        //volume automation
                        # yield null
                        yield WaitForSeconds(0.1f)
                        lineHeight = Color32()
                        for x in range(0, noteSectionLength * noteSection.loops, 16):

                            for y in range(h+1, h+1+127):
                                lineHeight = tex.GetPixel(x,y)
                                if lineHeight.g > 0f:
                                    print("x: " + x/16 + " => " + y)
                                    try:
                                        noteSection.automation.lineRenderer.points[x/16].y = (y-h) / 127f * noteSection.noteSectionRectTransform.rect.height
                                    except:
                                        print("automation error")
                                    break


        else:
            print("file does not exist")




    public def LoadWav(path as string):
        StartCoroutine(LoadWavRoutine(path))
        print (audioClip.length)

    public def LoadWavRoutine(path as string) as IEnumerator:
        # bytes as (byte)= File.ReadAllBytes(path)
        # print(bytes.Length)
        www  as WWW = WWW("file://" + path)
        audioClip = www.GetAudioClip()
        while not audioClip.isReadyToPlay:
            yield www

    

    public def LoadMidi(path as string):
        

        data = File.ReadAllBytes(path)
        pointer = 0
        if read_int(4) != Convert.ToInt32(0x4D546864):
            print('invalid file')
            return false
        header_size = read_int(4)
        print('header_size: ' + header_size)
        format_type = read_int(2)
        print('format_type: '+ format_type)
        tracks = read_int(2) - 1
        print('tracks: '+ tracks)
        time_division_byte_0 = read_int(1)
        time_division_byte_1 = read_int(1)

        if time_division_byte_0 >= 128:
            time_division_list = (0,0)
            time_division_list[0] = time_division_byte_0 - 128
            time_division_list[1] = time_division_byte_1
            print('time_division ppq: '+ time_division_list)
        else:
            time_division = (time_division_byte_0 * 256) + time_division_byte_1
            print('time_division fps: '+ time_division + '\n')

        for t in range(tracks+1):
            if read_int(4) != Convert.ToInt32(0x4D54726B):
                print(read_int(4) + ', invalid')
                break

            newNoteSection = musicScore.CreateNoteSection(musicScore.cursor.localPosition, 10000)
            for e in noteCache:
                e = 0
            x = 0
            notes = 0
            hasSetBMP = false
            Amvol.GetScaleChanger().SetScale("111111111111")

            chunk_length = read_int(4)
            print('chunk_length: ' + chunk_length)
            for i in range(data.Length):
                delta_time = read_int_vlv()
                //64th note = 0.015625
                dt as single = delta_time
                delta_time = Mathf.RoundToInt(dt / time_division / 4f / 0.015625f)

                status_byte = read_int(1)
                laststatus_byte = 0
                if status_byte >= 128:
                    laststatus_byte = status_byte
                else:
                    status_byte = laststatus_byte
                    pointer -= 1

                event_types = List of int()
                event_meta_types = List of int()
                b as byte = 0xFF
                if status_byte == b:
                    event_types.Add(Convert.ToInt32(0xFF))
                    meta_type = read_int(1)
                    event_meta_types.Add(meta_type)
                    event_length = read_int_vlv()
                    if meta_type == Convert.ToInt32(0x2F):
                        print('end')
                        break
                    elif meta_type == Convert.ToInt32(0x06):
                        print('marker: '+ read_int(event_length))
                    elif meta_type == Convert.ToInt32(0x51):
                        tempo = read_int(event_length)
                        # micro seconds per quarter note
                        bpm = tempo * 60 * 4 / 1000000
                        print('set bpm: '+ bpm)
                        if not hasSetBMP:
                            musicScore.SetBPM(bpm)
                            hasSetBMP = true
                        else:
                            print("todo: create tempo marker")
                    elif meta_type == Convert.ToInt32(0x58):
                        time_signature = read_int(1).ToString() + '/' + Mathf.Pow(2, read_int(1)).ToString()
                        pointer += 1

                        print('time signature: '+ time_signature)
                    else:
                        pointer += event_length
                        print('other: '+ read_int(event_length))

                elif status_byte:
                    status_byte_byte as string = status_byte.ToString("X")
                    if status_byte_byte.StartsWith('F'):
                        event_length = read_int_vlv()
                        pointer += event_length
                        break
                    elif status_byte_byte.StartsWith('8'):
                        noteIndex = read_int(1)
                        volume = noteCache[noteIndex]
                        for j in range(delta_time):
                            newNoteSection.SetNote(x-j, noteIndex, volume)
                        print(x + ', ' + 'note off: ' + noteIndex + ', ' + volume)
                    elif status_byte_byte.StartsWith('9'):
                        noteIndex = read_int(1)
                        volume = read_int(1) / 127f
                        noteCache[noteIndex] = volume
                        newNoteSection.SetNote(x-1, noteIndex, 0f)
                        notes += 1
                        print(x + ', ' + 'note on: '+ noteIndex + ', ' + volume)
                    elif status_byte_byte.StartsWith('D'):
                        pointer += 1

                    
                    x += delta_time

            if notes == 0:
                musicScore.noteSections.Remove(newNoteSection)
                Destroy(newNoteSection)

    def read_int(length as uint):
        returnValue = 0
        if length > 1:
            for i in range(1, length):
                try:
                    returnValue += data[pointer] * Mathf.Pow(256, (length - i))
                except:
                    print('overflow')
                pointer += 1

        returnValue += (data[pointer])
        pointer += 1
        return (returnValue)

    def read_int_vlv():
        returnValue = 0
        if((data[pointer])) < 128:
            returnValue = read_int(1)
        else:
            pieces = List of int()
            while (data[pointer]) >= 128:
                pieces.Add(read_int(1) - 128)
            last_byte = read_int(1)
            dt = 1
            while dt <= pieces.Count-1:
                returnValue = pieces[pieces.Count-1 - dt] * Mathf.Pow(128, dt)
                dt += 1
            returnValue += last_byte
        return returnValue

    def Update():
        if Input.GetKeyDown(KeyCode.P):

            LoadMidi("E:\\UnityProjects\\Amvol\\Midi\\midiFileTest2.mid")