import UnityEngine
import UnityEngine.UI.Extensions


class GridRenderer (MonoBehaviour): 

    public thickness as single
    public material as Material

    public spacingX as int = 1
    public spacingY as int = 1

    def Awake():
        rectTransform = gameObject.GetComponent(RectTransform)
        width = rectTransform.sizeDelta.x
        height = rectTransform.sizeDelta.y

        lineRenderer = gameObject.AddComponent(UILineRenderer)
        # lineRenderer.positionCount = (width / spacingX) + (height / spacingY)
        lineRenderer.material = material
        lineRenderer.lineThickness = thickness

        points = List of Vector2()
        for x in range(width):
            points.Add(Vector2(x*spacingX, 0))
            points.Add(Vector2(x*spacingX, height))
            points.Add(Vector2((x*spacingX)+spacingX, height))

        for y in range(height):
            points.Add(Vector2(width*spacingX, y*spacingY))
            points.Add(Vector2(0, y*spacingY))
            points.Add(Vector2(0, (y*spacingY)+spacingY))

        lineRenderer.points = points.ToArray()
