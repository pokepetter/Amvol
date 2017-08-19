import UnityEngine
import UnityEngine.UI.Extensions


class GridRenderer (MonoBehaviour):

    public thickness as single
    public material as Material
    public gridColor as Color

    public spacingX as int = 1
    public spacingY as int = 1

    private rectTransform as RectTransform
    public lineRenderer as UILineRenderer
    private width as int
    private height as int

    def Awake():
        rectTransform = gameObject.GetComponent(RectTransform)
        lineRenderer = gameObject.AddComponent(UILineRenderer)
        lineRenderer.raycastTarget = false
        lineRenderer.color = gridColor
        DrawGrid()


    def DrawGrid():
        try:
            width = rectTransform.rect.width

            height = rectTransform.rect.height

            lineRenderer.material = material
            lineRenderer.lineThickness = thickness

            points = List of Vector2()

            if spacingX == 0:
                spacingX = width

            for x in range(0, width, spacingX):
                points.Add(Vector2(x, 0))
                points.Add(Vector2(x, height))
                points.Add(Vector2((x)+spacingX, height))

            if spacingY == 0:
                spacingY = height

            points.Add(Vector2(width * spacingX, height * spacingY))
            for y in range(0, height, spacingY):
                points.Add(Vector2(width*spacingX, y))
                points.Add(Vector2(0, y))
                points.Add(Vector2(0, (y)+spacingY))

            lineRenderer.points = points.ToArray()

            lineRenderer.enabled = false
            lineRenderer.enabled = true
        except:
            print("failed to draw grid")
