import UnityEngine
import UnityEngine.UI
import System.IO


public class FileBrowser (MonoBehaviour):

    public drives as (string)
    public folders as (string)
    public files as (string)
    public allFiles as (string)

    public defaultDirectory as string

    public currentDirectory as string
    public parentDirectory as string

    [SpaceAttribute(50)]
    public loadMenuWindow as Transform
    public loadMenuButton as GameObject
    public content as Transform
    public fileNameField as InputField
    public directoryNameField as Text
    public folderPath as string

    private currentFileType as string

    private targetScale as Vector3

    def Awake():
        drives = System.IO.Directory.GetLogicalDrives()



        transform.localPosition = Vector3.zero
        gameObject.SetActive(false)



    def OnEnable():
        configFilePath = Path.Combine(System.IO.Directory.GetCurrentDirectory(), "config.txt")
        try:
            line as string
            file as StreamReader = StreamReader(configFilePath, Encoding.Default)

            while (line = file.ReadLine()) != null:
                words as (string) = line.Split(char.Parse(" "))
                for i in range(words.Length):
                    if words[i] == "project_folder:":
                        if System.IO.Directory.Exists(words[i+1]):
                            defaultDirectory = words[i+1]
                        else:
                            defaultDirectory = System.IO.Directory.GetCurrentDirectory()
            file.Close()
        except:
            defaultDirectory = System.IO.Directory.GetCurrentDirectory()

        currentDirectory = defaultDirectory
        parentDirectory = System.IO.Directory.GetParent(currentDirectory).FullName
        allFiles = System.IO.Directory.GetFileSystemEntries(currentDirectory)
        UpdateFileList(".png")
        Amvol.instance.keyboardPlayer.blockInput = true

        //hacky
        headerText = Amvol.instance.saveSystem.header.text
        if headerText != 'Amvol':
        	fileNameField.text = Path.GetFileName(headerText).Split(char.Parse('.'))[0]



    def OnDisable():
        Amvol.instance.keyboardPlayer.blockInput = false



    public def UpdateFileList(fileType as string):
        currentFileType = "*" + fileType
        directoryNameField.text = currentDirectory

        DeleteChildren()

        if Directory.GetParent(currentDirectory) != null:
            parentDirectory = Directory.GetParent(currentDirectory).FullName

        folders = Directory.GetDirectories(currentDirectory)
        files = Directory.GetFileSystemEntries(currentDirectory, currentFileType)

        i as int = 0
        while i < folders.Length:
            instFolder = Instantiate(loadMenuButton).transform
            instFolder.SetParent(content, false)
            instFolder.position.y = (i*3)-5
            instFolder.GetComponent(FileButton).SetPath(folders[i])
            instFolder.GetComponent(FileButton).fileBrowser = self
            if currentDirectory.Length+1 < folders[i].Length:
                instFolder.GetChild(0).GetComponent(Text).text = folders[i].Remove(0, currentDirectory.Length+1)
            i++

        seperator = Instantiate(loadMenuButton).transform
        seperator.SetParent(content, false)
        seperator.position.y = (i*3)-5
        seperator.GetChild(0).GetComponent(Text).text = "---------------------"
        Destroy(seperator.GetComponent(Button))

        i = 0
        while i < files.Length:
            clone = Instantiate(loadMenuButton).transform
            clone.SetParent(content, false)
            clone.position.y = (i*3)-5
            clone.GetComponent(FileButton).SetPath(files[i])
            clone.GetComponent(FileButton).fileBrowser = self
            if currentDirectory.Length+1 < files[i].Length:
                clone.GetChild(0).GetComponent(Text).text = files[i].Remove(0, currentDirectory.Length+1)
            i++

        content.localPosition.y = 0


    public def SelectFile(fileName as string):
        currentDirectory = fileName
        fileNameField.text = fileName

    public def FolderUp():
        currentDirectory = parentDirectory
        UpdateFileList(currentFileType)

    private def DeleteChildren():
        if content.childCount > 0:
            arr = content.GetComponentsInChildren[of Transform]()
            for child in arr:
                if content.childCount > 0:
                    DestroyImmediate(content.GetChild(0).gameObject)


    public def LoadFile():
        if currentDirectory.Substring(currentDirectory.Length-4) == ".wav":
            print("load .wav")
            audioClips as List of AudioClip
            # audioClips.Add(Amvol.GetSaveSystem().LoadWav(currentDirectory))
            Debug.LogError("not implemented yet")
            startNotes as List of int
            startNotes.Add(60)

            Amvol.GetInstrumentChanger().ReplaceInstrument(audioClips, startNotes, 0.05f, 0.5f, false, false, Color.grey)
        if currentDirectory.Substring(currentDirectory.Length-4) == ".png":
            Amvol.GetSaveSystem().Load(currentDirectory)
        if currentDirectory.Substring(currentDirectory.Length-4) == ".mid":
            Amvol.GetSaveSystem().LoadMidi(currentDirectory)
        # if currentFileType == "instrument":

        else:

            UpdateFileList(currentFileType)

    # def FixedUpdate():
    #     transform.localScale = Vector3.Lerp(transform.localScale, targetScale, Time.deltaTime * 15f)
