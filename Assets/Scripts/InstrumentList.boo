import UnityEngine
import UnityEngine.UI

class InstrumentList (MonoBehaviour): 
    
    public instrumentButton as GameObject
    public folderButton as GameObject
    public content as RectTransform
    public scrollView as RectTransform
    private files as (string)
    public instrumentDirectory as string
    private isOpen as bool

    public debugPaths as (string)
    public debugStartNotes as (int)

    private instrumentChanger as InstrumentChanger

    public def Start():
        instrumentChanger = Amvol.GetInstrumentChanger()
        transform.localPosition = Vector2.zero

    def Select():
        instrumentChanger.SetCurrentInstrument(transform.GetComponent(Instrument))

    public def OpenList():
        if isOpen:
            isOpen = false
            if content.childCount > 0:
                arr = content.GetComponentsInChildren[of Transform]()
                for child in arr:
                    if content.childCount > 0:
                        DestroyImmediate(content.GetChild(0).gameObject)
            scrollView.sizeDelta.y = 0
            scrollView.gameObject.SetActive(false)

        else:
            isOpen = true
            scrollView.gameObject.SetActive(true)
            currentDirectory as string = System.IO.Directory.GetCurrentDirectory()

            addedPath = "Instruments"

            instrumentDirectory = Path.Combine(currentDirectory, addedPath)
            ShowFolderContent(addedPath)

    public def ShowFolderContent(instrumentDirectory as string):
        currentDirectory = System.IO.Directory.GetCurrentDirectory()
        instrumentDirectory = Path.Combine(currentDirectory, instrumentDirectory)
        # folders = Directory.GetDirectories(instrumentDirectory)
        files = Directory.GetFileSystemEntries(instrumentDirectory, "*.wav")
        # content.sizeDelta.y = files.Length
        # scrollView.sizeDelta.y = files.Length

        # for c in folders:
        #     clone = Instantiate(folderButton)
        #     clone.transform.SetParent(content, false)

        #     clone.transform.GetComponent(InstrumentButton).SetPath(c)
        #     folderName as string = c.Remove(0, instrumentDirectory.Length+1)
        #     words = folderName.Split(Char.Parse("-"), Char.Parse("."), Char.Parse("_"))
        #     name = words[0]
        #     clone.transform.GetChild(0).GetComponent(Text).text = folderName
        #     clone.transform.GetComponent(InstrumentButton).SetName(folderName)

        i as int = 0
        paths = List of string()
        startNotes = List of int()
        buttonPosition = 0
        while i < files.Length:
            clone = Instantiate(instrumentButton)
            clone.transform.SetParent(content, false)
            clone.transform.localPosition.y = buttonPosition
            scrollView.sizeDelta.y = buttonPosition+1
            # content.sizeDelta.y = scrollView.sizeDelta.y+1
            buttonPosition++

            paths.Clear()
            startNotes.Clear()
            paths.Add(files[i])

            fullName as string = files[i].Remove(0, instrumentDirectory.Length+1)
            # print(fullName)
            words = fullName.Split(Char.Parse("-"), Char.Parse("."), Char.Parse("_"))
            for e in words:
                if e[0] == Char.Parse("n"):
                    startNoteString as string = e.Remove(0,1)
                    startNotes.Add(int.Parse(startNoteString))
            name = words[0]
            clone.name = name
            clone.transform.GetChild(0).GetComponent(Text).text = name

            j as int = 1
            while j < 16:
                if i+j < files.Length:
                    nextFullName as string = files[i+j].Remove(0, instrumentDirectory.Length+1)
                    nextWords = nextFullName.Split(Char.Parse("-"), Char.Parse("."), Char.Parse("_"))
                    nextName = nextWords[0]
                    if nextName == name:
                        paths.Add(files[i+j])
                        for e in nextWords:
                            if e[0] == Char.Parse("n"):
                                nextStartNoteString as string = e.Remove(0,1)
                                startNotes.Add(int.Parse(nextStartNoteString))
                        i++
                        j = 0
                j++
            clone.transform.GetComponent(InstrumentButton).SetPaths(paths, startNotes)
            //for debug
            x as int = 0
            debugPaths = array(string, paths.Count)
            while x < paths.Count:
                debugPaths[x] = paths[x]
                x++

            x = 0
            debugStartNotes = array(int, startNotes.Count)
            while x < startNotes.Count:
                debugStartNotes[x] = startNotes[x]
                x++


            i++
