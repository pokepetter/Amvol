import UnityEngine
import System.Collections

class SetNoteSize (MonoBehaviour, IPointerDownHandler):

    public zoomLevel as int = 3

    def OnPointerDown(ped as PointerEventData):
        if ped.button == PointerEventData.InputButton.Left:
	            Amvol.instance.musicScore.ZoomCanvas(zoomLevel)

            for i in range(transform.parent.childCount):
                transform.parent.GetChild(i).GetChild(0).gameObject.SetActive(false)
            transform.GetChild(0).gameObject.SetActive(true)
