import UnityEngine
import UnityEngine.UI
import System.Text
import System.IO

class ScaleList (MonoBehaviour): 
    
    public scaleButton as GameObject
    public content as RectTransform
    public scrollView as RectTransform
    private scales as List of string
    private scaleNames as List of string
    private scaleChanger as ScaleChanger

    public def Awake():
        scales = List of string()
        scaleNames = List of string()

    public def Start():
        content.GetComponentInChildren(ScaleButton).SelectScale()


    public def OnEnable():
        if content.childCount > 0:
            arr = content.GetComponentsInChildren[of Transform]()
            for child in arr:
                if content.childCount > 0:
                    DestroyImmediate(content.GetChild(0).gameObject)

        currentDirectory = System.IO.Directory.GetCurrentDirectory()
        filePathToAdd = "scales.txt"

        ShowTextFile(Path.Combine(currentDirectory, filePathToAdd))


    public def ShowTextFile(fileName as string):
        line as string
        file as StreamReader = StreamReader(fileName, Encoding.Default)
        
        while (line = file.ReadLine()) != null:
            entries as (string) = line.Split(Char.Parse(","))
            if entries.Length > 0:
                scales.Add(entries[0])

                if entries.Length > 1:
                    scaleNames.Add(entries[1])
                else:
                    scaleNames.Add(entries[0])

        file.Close()

        buttonPosition = 0
        i as int = 0
        while i < scales.Count:
            clone = Instantiate(scaleButton)
            clone.transform.SetParent(content, false)
            buttonPosition++
            
            clone.transform.GetComponent(ScaleButton).scalePattern = (scales[i])
            clone.transform.GetComponentInChildren(Text).text = scales[i] + " (" + scaleNames[i] + ")"

            i++
