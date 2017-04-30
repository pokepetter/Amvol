import UnityEngine
import UnityEngine.UI

[ExecuteInEditMode]
class GUIColors (MonoBehaviour): 
    
    public palette as Texture2D
    public x as int
    public y as int

    def Awake():
        if palette != null:
            color = palette.GetPixel(x,y)
            if transform.GetComponent(Image) != null:
                transform.GetComponent(Image).color = color
            if transform.GetComponent(Text) != null:
                transform.GetComponent(Text).color = color
            # if transform.GetComponent(Outline) != null:
            #     transform.GetComponent(Outline).effectColor = color
