import UnityEngine
import UnityEngine.UI
import UnityEngine.EventSystems

class RightClickMenu (MonoBehaviour, IPointerDownHandler): 
    
    public menu as GameObject

    public def OnPointerDown(ped as PointerEventData):
        print(ped.pressPosition)
        if ped.button == PointerEventData.InputButton.Right:
            if menu != null:
                localCursorPosition = Vector2.zero
                if RectTransformUtility.ScreenPointToLocalPointInRectangle(transform.GetComponent(RectTransform), ped.position, ped.pressEventCamera, localCursorPosition):
                    menu.transform.localPosition = localCursorPosition
                menu.SetActive(true)