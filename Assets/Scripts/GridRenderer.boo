import UnityEngine
import UnityEngine.UI.Extensions


class GridRenderer (MonoBehaviour): 

    public thickness as single
    public material as Material

    public spacingX as int = 1
    public spacingY as int = 1

    private rectTransform as RectTransform
    private lineRenderer as UILineRenderer 

    def Awake():
        rectTransform = gameObject.GetComponent(RectTransform)
        lineRenderer = gameObject.AddComponent(UILineRenderer)
        DrawGrid()


    def DrawGrid():
        width = rectTransform.rect.width / spacingX
        height = rectTransform.rect.height

        lineRenderer.material = material
        lineRenderer.lineThickness = thickness

        points = List of Vector2()
        if spacingX > 0:
            for x in range(width):
                points.Add(Vector2(x*spacingX, 0))
                points.Add(Vector2(x*spacingX, height))
                points.Add(Vector2((x*spacingX)+spacingX, height))

        if spacingY > 0:
            for y in range(height):
                points.Add(Vector2(width*spacingX, y*spacingY))
                points.Add(Vector2(0, y*spacingY))
                points.Add(Vector2(0, (y*spacingY)+spacingY))

        lineRenderer.points = points.ToArray()

        lineRenderer.enabled = false
        lineRenderer.enabled = true
