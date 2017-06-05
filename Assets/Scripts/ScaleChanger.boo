import UnityEngine
import System.Collections.Generic

class ScaleChanger (MonoBehaviour): 

    public scaleLength as int
    public alkmScale as (int)
    public currentScale as string
    private octaveLength as int
    public firstHalf as (char)
    public secondHalf as (char)
    
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
        
        firstHalf = array(char, scaleOffset)
        secondHalf = array(char, scaleLength - scaleOffset)

        i as int = 0

        while i < firstHalf.Length:
            firstHalf[i] = charArray[i]
            i++

        i = 0
        while i < secondHalf.Length:
            secondHalf[i] = charArray[i+scaleOffset]
            i++
        
        charArray = array(char, secondHalf + firstHalf)


        alkmScale = array(int, scaleLength)
        j = 0
        alkmScale[0] = 0
        i = 1
        while i < charArray.Length:
            if charArray[i-1] == Char.Parse("3"):
                j += 3
                alkmScale[i] = j
            if charArray[i-1] == Char.Parse("2"):
                j += 2
                alkmScale[i] = j
            if charArray[i-1] == Char.Parse("1"):
                j += 1
                alkmScale[i] = j
            # else:
                # print(charArray[i])
            i++

        Amvol.GetKeyboardPlayer().UpdateNoteNames()


    def NoteOffset(y as int, normalizeWithinOctave as bool) as int: //return this to the NoteSection
        if normalizeWithinOctave == true:
            octaveLength = 0
        else:
            octaveLength = 12

        if y < alkmScale.Length:
            return alkmScale[y] + noteOffset
        elif y >= alkmScale.Length and y < alkmScale.Length * 2:
            return alkmScale[y-alkmScale.Length] + octaveLength + noteOffset
        elif y >= alkmScale.Length * 2 and y < alkmScale.Length * 3:
            return alkmScale[y-alkmScale.Length*2] + octaveLength*2 + noteOffset
        elif y >= alkmScale.Length * 3 and y < alkmScale.Length * 4:
            return alkmScale[y-alkmScale.Length*3] + octaveLength*3 + noteOffset
        elif y >= alkmScale.Length * 4 and y < alkmScale.Length * 5:
            return alkmScale[y-alkmScale.Length*4] + octaveLength*4 + noteOffset
        elif y >= alkmScale.Length * 5 and y < alkmScale.Length * 6:
            return alkmScale[y-alkmScale.Length*5] + octaveLength*5 + noteOffset
        elif y >= alkmScale.Length * 6 and y < alkmScale.Length * 7:
            return alkmScale[y-alkmScale.Length*6] + octaveLength*6 + noteOffset
        elif y >= alkmScale.Length * 7 and y < alkmScale.Length * 8:
            return alkmScale[y-alkmScale.Length*7] + octaveLength*7 + noteOffset
        elif y >= alkmScale.Length * 8 and y < alkmScale.Length * 9:
            return alkmScale[y-alkmScale.Length*8] + octaveLength*8 + noteOffset
        elif y >= alkmScale.Length * 9 and y < alkmScale.Length * 10:
            return alkmScale[y-alkmScale.Length*9] + octaveLength*9 + noteOffset
        else:
            return 0

    public def GetScaleLength() as int:
        return scaleLength