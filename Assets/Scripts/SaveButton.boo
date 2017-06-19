﻿import UnityEngine
import UnityEngine.UI

class SaveButton (MonoBehaviour): 

    public inputField as Text
    public folderField as Text
    public fullPath as string
    private button as Button

    def Awake():
        button = GetComponent(Button)
        button.onClick.AddListener({Save()})

    private def Save() as callable:
        Amvol.GetSaveSystem().Save(Path.Combine(folderField.text, inputField.text))
