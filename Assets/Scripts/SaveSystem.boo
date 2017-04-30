import UnityEngine
import System.IO
import System.Collections
import System.BitConverter

public class SaveSystem (MonoBehaviour): 
    
    public instrumentChanger as InstrumentChanger
    public musicScore as MusicScore
    public scaleChanger as ScaleChanger
    public instrumentStringParts as (string)

    private tex as Texture2D
    private rect as Rect
    private bytes as (byte)
    private x as int
    private y as int
    private audioClip as AudioClip

    public def Save(saveName as string):
        tex = Texture2D.blackTexture
        
        //find document length
        noteSections = Amvol.GetMusicScore().noteSections
        if noteSections.Count == 0:
            print('nothing to save')
        else:
            endPoint = 0
            for noteSection in noteSections:
                if noteSection.transform.localPosition.x + noteSection.transform.GetComponent(RectTransform).sizeDelta.x > endPoint:
                    endPoint = noteSection.transform.localPosition.x + noteSection.transform.GetComponent(RectTransform).sizeDelta.x
            width = endPoint * 8
            print(width)

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
            posX = noteSection.transform.localPosition.x * 8

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
            tex.SetPixel(((noteSection.transform.localPosition.x * 8) + noteSection.transform.GetComponent(RectTransform).sizeDelta.x * 8) -1, (noteSection.transform.localPosition.y * 32) +2, Color.blue)
            
            //save notes
            while y < 128 and x < noteSection.transform.GetComponent(RectTransform).sizeDelta.x * 8:
                tex.SetPixel((noteSection.transform.localPosition.x * 32) + x, (noteSection.transform.localPosition.y * 32) + y +2, Color(noteSection.notes[x,y], 0, 0))
                y++
                if y == 128:
                    y = 1
                    x++



        bytes = tex.EncodeToPNG()
        
        print("saved to"+Application.dataPath + "/" + saveName)
        # imageData = File.ReadAllBytes(Application.dataPath + "/" + saveName + ".png")

        # firstPart = bytes.Take(29).ToArray()
        # lastPart = bytes.Skip(37).Take(bytes.Length-37).ToArray()

        # //add instrument names to comment
        # instrumentInfo = ".tEXtComment" + Char.Parse("\0") + "Instruments: "
        # for instrument in instrumentChanger.instruments:
        #     instrumentInfo += instrument.gameObject.name + ", "
        # instrumentInfo += "1™½ò" + Char.Parse("\0") + Char.Parse("\0") + Char.Parse("\0") + ""
        # middlePart = Encoding.UTF8.GetBytes(instrumentInfo)
        
        # bytes  = firstPart + middlePart + lastPart
        instrumentInfo = "Instruments: "
        for i in range(instrumentChanger.instruments.Count):
            instrument = instrumentChanger.instruments[i]
            instrumentInfo += instrument.gameObject.name
            if i < instrumentChanger.instruments.Count -1:
                instrumentInfo += ", "
        instrumentBytes = Encoding.UTF8.GetBytes(instrumentInfo)

        bytes += instrumentBytes

        File.WriteAllBytes(Application.dataPath + "/" + saveName + ".png", bytes)

    public def Load(path as string):
        if File.Exists(path):
            fileData = File.ReadAllBytes(path)
            tex = Texture2D.blackTexture
            tex.LoadImage(fileData)//..this will auto-resize the texture dimensions.

            instrumentChanger.ClearAllInstruments()

            instrumentString = Encoding.UTF8.GetString(fileData)
            instrumentStringParts = Regex.Split(instrumentString, "Instruments: ")
            if instrumentStringParts.Length > 0:
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

            for h in range(tex.height):
                for w in range(tex.width):
                    //find note section start
                    if tex.GetPixel(w,h) == Color.green:
                        # print("found note section start")
                        startPosition = w
                        i = startPosition
                        //find note section end
                        while i <= tex.width:
                            if tex.GetPixel(i,h) == Color.blue:
                                # print("found note section end")
                                noteSectionLength = i - startPosition +1
                                break
                            i++ 

                        noteSection = musicScore.CreateNoteSection(Vector2(w /8, Mathf.FloorToInt((h-2)/32)), noteSectionLength)
                        instIndex as Color32 = tex.GetPixel(w+1, h)
                        print(instIndex.r)
                        noteSection.UpdateInstrument(instrumentChanger.instruments[instIndex.r])

                        for x in range(noteSectionLength):
                            for y in range(128):
                                noteSection.SetNote(x, y, tex.GetPixel(w+x, h+y).r)                        

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

    

    public def LoadMid(path as string):
        bytes as (byte)= File.ReadAllBytes(path)
        noteSection = Amvol.GetMusicScore().CreateNoteSection(Vector2.zero, 1000)
        noteSection.transform.localPosition = Vector2.zero

        i as int = 0
        cumNoteTime as single = 0
        cumTempoTime as int = 0

        trackLengthInfo as string = "MTrk"
        noteOnMessage as byte = 0x90
        noteOffMessage as byte = 0x80
        tempoChange as (byte) = array(byte, (0xff, 0x51, 0x03))
        deltaTime as int
        n as int

        while i < bytes.Length:
            if bytes[i] == noteOnMessage:

                if bytes[i-1] != 0x00:
                    cumNoteTime += (bytes[i-2] - bytes[i-1] + 1) /8

                noteList as List of int = List [of int]()
                velocityList as List of int = List [of int]()

                noteList.Add(bytes[i+1])
                velocityList.Add(bytes[i+2])
                e as int = 3
                while e < 16:
                    if bytes[i+e] == 0x00:
                        noteList.Add(bytes[i+e+1])
                        velocityList.Add(bytes[i+e+2])
                        e += 3
                    else:
                        break

                n = 0
                while n < noteList.Count:
                    for j in range((bytes[i+e] - bytes[i+e+1] + 1) /8):
                        cumNoteTime++
                        noteSection.SetNote(cumNoteTime-1, noteList[n]-24, velocityList[n] /127f)
                    if n < noteList.Count-1:
                        cumNoteTime -= (bytes[i+e] - bytes[i+e+1] + 1) /8
                    n++
  

            if bytes[i] == noteOffMessage:
                noteListOff as List of int = List [of int]()

                noteListOff.Add(bytes[i+1])
                o as int = 3
                while o < 16:
                    if bytes[i+o] != 0x00 and bytes[i+o+1] != 0x90:
                        cumNoteTime += (bytes[i+o] - bytes[i+o+1] + 1) /8
                        break
                    else:
                        o += 3
                

                # o as int = 3
                # for j in range(16):
                #     if bytes[i+o] != 0x00 and bytes[i+o+1] != 0x90:
                #         cumNoteTime = cumNoteTime + ((bytes[i+o] - bytes[i+o+1] + 1) /8)
                #         print(bytes[i+o] +" / "+ bytes[i+o+1])
                #         break
                #     else:
                #         o += 3
                        


            if bytes[i] == tempoChange[0] and bytes[i+1] == tempoChange[1] and bytes[i+2] == tempoChange[2]:
                tempoBytesDecimal as int = bytes[i+3] << 16 + bytes[i+4] << 8 + bytes[i+5]
                newBPM as int = 60000000f/tempoBytesDecimal
                cumTempoTime += bytes[i]
                if cumTempoTime == 0:
                    Amvol.GetMusicScore().SetBPM(newBPM)
                    
                else:
                    Amvol.GetMusicScore().CreateTempoMarker(((cumTempoTime/64)-3) * 8, newBPM)
                # print(((cumTempoTime/64)-3) + " set bpm to " + newBPM)
                # print(60000000f/tempoBytesDecimal)

            i++

    # private def CreateNote(noteLength as (byte)):
    #     if noteLength[0] == 0x87 and noteLength[1] == 0x68:
    #         for j in range(8):
    #             cumNoteTime++
    #             noteCanvas.SetNote(cumNoteTime-1, bytes[i+1]-24, bytes[i+2] /100f)
    #     if bytes[i+3] == 0x83 and bytes[i+4] == 0x74:
    #         for j in range(4):
    #             cumNoteTime++
    #             noteCanvas.SetNote(cumNoteTime-1, bytes[i+1]-24, bytes[i+2] /100f)

    #     if bytes[i+3] == 0x81 and bytes[i+4] == 0x7a:
    #         for j in range(2):
    #             cumNoteTime++
    #             noteCanvas.SetNote(cumNoteTime-1, bytes[i+1]-24, bytes[i+2] /100f)


    public def Update():
        if Input.GetKey(KeyCode.LeftShift) and Input.GetKeyDown(KeyCode.S):
            Save("debugSave")

        if Input.GetKey(KeyCode.LeftShift) and Input.GetKeyDown(KeyCode.L):
            Load(Application.dataPath + "/debugSave.png")

        # if Input.GetKey(KeyCode.LeftShift) and Input.GetKey(KeyCode.L):
        #     try:
        #         LoadMid("D:/Audiogen/Assets/liberty.mid")
        #     except:
        #         pass

        #     try:
        #         LoadMid("E:/Audiogen/Assets/liberty.mid")
        #     except:
        #         pass