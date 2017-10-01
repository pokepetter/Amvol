import UnityEngine
import System.Collections.Generic

class ScaleChanger (MonoBehaviour): 

    public scaleLength as int
    public alkmScale as List of int
    public currentScale as string
    private octaveLength as int
    # public firstHalf as (char)
    # public secondHalf as (char)
    
    public scaleOffset as int = 0
    public noteOffset as int = 0
    
     
    def SetScaleOffset(offset as single):
        scaleOffset = offset
        SetScale()
        Amvol.GetKeyboardPlayer().UpdateNoteNames()

    def SetRootNote(offset as single):
        noteOffset = offset
        SetScale()
        Amvol.GetKeyboardPlayer().UpdateNoteNames()
        
    def SetScale():
        SetScale(currentScale)

    def SetScale(scale as string):
        currentScale = scale
        charArray = scale.ToCharArray()
        scaleLength = charArray.Length

        charList = [e for e in charArray]

        for i in range(scaleOffset):
            firstChar = charList[0]
            charList.Add(firstChar)
            charList.RemoveAt(0)

        # charArray = array(char, charList)

        s = ""
        for c in charList:
            s += c.ToString()
        print('setting scale: ' + s)

        alkmScale = List of int()
        cumulative = 0

        for i in range(charList.Count):
            cumulative += Char.GetNumericValue(charList[i])
            alkmScale.Add(cumulative)


        Amvol.GetKeyboardPlayer().UpdateNoteNames()


    def NoteOffset(y as int, normalizeWithinOctave as bool) as int: //return this to the NoteSection
        if y == 0:
            print("no note on 0")
            return 0

        sL as single = (y-1f) / (scaleLength)
        filledOctaves = Mathf.FloorToInt(sL)
        # print("filled octaves: " + sL + " / " + filledOctaves)
        o = filledOctaves * 12
        
        offset = alkmScale[y - (filledOctaves * (scaleLength)) - 1]

        if normalizeWithinOctave:
            if offset + noteOffset > 12:
                return (offset + noteOffset) - 12
                
            return offset + noteOffset

        # print("y: " + y + " => " + o + " + " + offset)
        return o + offset + noteOffset


    public def GetScaleLength() as int:
        return scaleLength