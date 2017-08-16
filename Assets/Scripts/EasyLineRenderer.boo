import UnityEngine
import UnityEngine.EventSystems
import UnityEngine.UI.Extensions


class EasyLineRenderer (MonoBehaviour, IDragHandler):

    public thickness as single
    public material as Material

    public spacingX as single = 1

    public rectTransform as RectTransform
    public lineRenderer as UILineRenderer


    def DrawGrid():
        points = List of Vector2()
        if spacingX > 0:
            for x in range(rectTransform.rect.width+1):
                points.Add(Vector2(x*spacingX, rectTransform.rect.height / 2))

        lineRenderer.points = points.ToArray()
        lineRenderer.enabled = false
        lineRenderer.enabled = true


    def OnDrag(ped as PointerEventData):
        localCursorPosition as Vector2
        i as int = 0
        if RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform, ped.position, ped.pressEventCamera, localCursorPosition):
            localCursorPosition = Vector2(Mathf.Clamp(Mathf.RoundToInt(localCursorPosition.x), 0, rectTransform.rect.width),
                                          Mathf.Clamp(localCursorPosition.y, 0, rectTransform.rect.height))
            lineRenderer.points[localCursorPosition.x].y = localCursorPosition.y
            lineRenderer.enabled = false
            lineRenderer.enabled = true
