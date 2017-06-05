import UnityEngine
import UnityEngine.UI
import UnityEngine.EventSystems

class RightClickMenu (MonoBehaviour, IPointerDownHandler): 
    
    public menu as GameObject

    public def OnPointerDown(ped as PointerEventData):
        
        if ped.button == PointerEventData.InputButton.Right:
            if menu != null:
                menu.transform.parent = GameObject.Find("RightClickMenuParent").transform
                cursorPosition = Vector3.zero

                if RectTransformUtility.ScreenPointToWorldPointInRectangle(transform.GetComponent(RectTransform), ped.position, ped.pressEventCamera, cursorPosition):
                    menu.transform.position = cursorPosition
                menu.SetActive(true)