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


    def Close():
        # clear
        for child in content.GetComponentsInChildren[of Transform]():
            if child != content:
                Destroy(child.gameObject)

        scrollView.gameObject.SetActive(false)
        print('close')


    public def ShowFolderContent(relativeDirectory as string):
        print("relativeDirectory: " + relativeDirectory)
        instrumentDirectory = Path.Combine(System.IO.Directory.GetCurrentDirectory(), relativeDirectory)

        folders = Directory.GetDirectories(instrumentDirectory)
        files = Directory.GetFileSystemEntries(instrumentDirectory, "*.wav")
        Array.Reverse(folders)
        Array.Reverse(files)

        Close()
        scrollView.gameObject.SetActive(true)

        paths = List of string()
        startNotes = List of int()
        buttonPosition = 0
        foundIntruments = List of string()
        print('yo')
        for file in files:
            # print(Path.GetFileName(file))
            words = Path.GetFileName(file).Split(Char.Parse("-"), Char.Parse("."), Char.Parse("_"))

            if foundIntruments.Contains(words[0]):
                continue
            foundIntruments.Add(words[0])

            clone = Instantiate(instrumentButton)
            clone.transform.SetParent(content, false)
            clone.transform.localPosition.y = buttonPosition
            clone.name = words[0]
            clone.transform.GetChild(0).GetComponent(Text).text = words[0]

            paths.Clear()
            startNotes.Clear()
            paths.Add(file)

            for word in words:
                if word.StartsWith("n"):
                    startNotes.Add(int.Parse(word.Remove(0,1)))


            for otherFile in files:
                if otherFile == file:
                    continue

                otherFileWords = Path.GetFileName(otherFile).Split(Char.Parse("-"), Char.Parse("."), Char.Parse("_"))
                if otherFileWords[0] == words[0]:   // found match
                    paths.Add(otherFile)

                    for otherWord in otherFileWords:
                        if otherWord.StartsWith("n"):
                            startNotes.Add(int.Parse(otherWord.Remove(0,1)))

            for i in range(Mathf.Max(0, startNotes.Count - paths.Count)):
                startNotes.Add(0)

            try:
                clone.transform.GetComponent(InstrumentButton).SetPaths(paths, startNotes)
            except:
                Destroy(clone)
                print("invalid insturment")


        for folder in folders:
            cloneF = Instantiate(folderButton)
            cloneF.transform.SetParent(content, false)
            cloneF.transform.GetComponent(InstrumentFolderButton).path = Path.Combine(relativeDirectory, Path.GetFileName(folder))
            cloneF.transform.GetChild(0).GetComponent(Text).text = Path.GetFileName(folder)
            cloneF.name = Path.GetFileName(folder)
            # cloneF.transform.GetComponent(InstrumentFolderButton).SetName(folderName)

        if relativeDirectory != "Instruments":
            backButton = Instantiate(folderButton)
            backButton.transform.SetParent(content, false)
            backButton.transform.GetComponent(InstrumentFolderButton).path = Directory.GetParent(relativeDirectory).ToString()
            backButton.name = "<<<<<"
            backButton.transform.GetChild(0).GetComponent(Text).text = "<<<<<"


        content.sizeDelta.y = foundIntruments.Count + folders.Length + 1
        scrollView.sizeDelta.y = foundIntruments.Count + folders.Length + 1

            //for debug
            # x as int = 0
            # debugPaths = array(string, paths.Count)
            # while x < paths.Count:
            #     debugPaths[x] = paths[x]
            #     x++

            # x = 0
            # debugStartNotes = array(int, startNotes.Count)
            # while x < startNotes.Count:
            #     debugStartNotes[x] = startNotes[x]
            #     x++
