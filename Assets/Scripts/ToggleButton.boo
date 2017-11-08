import UnityEngine
import UnityEngine.UI

class ToggleButton (MonoBehaviour): 
    
    public toggledGraphic as Transform
    public keyboardPlayer as KeyboardPlayer
    public toggleActive as bool = true
    private button as Button
    public targetScale as Vector2
    private elapsedTime as single
    private t as single

    def Start():
        button = GetComponent(Button)
        button.onClick.AddListener({Toggle()})
        toggledGraphic.localPosition = Vector2.zero
        toggledGraphic.localScale = Vector2.zero
        targetScale = Vector2.zero

        if keyboardPlayer == null:
            keyboardPlayer = Amvol.GetKeyboardPlayer()

    public def Toggle():
        if toggledGraphic.localScale.x < 0.9f:
            StartCoroutine(ScaleRoutine(Vector2.one, 0.1f))
                
        elif gameObject.activeSelf:
            StartCoroutine(ScaleRoutine(Vector2.zero, 0.05f))


    private def ScaleRoutine(targetScale as Vector2, time as single) as IEnumerator:
        elapsedTime = 0f
        t = 0f
        startValue = toggledGraphic.localScale
        if targetScale != Vector2.zero and toggleActive:
        	toggledGraphic.gameObject.SetActive(true)

        while elapsedTime < time:
            yield WaitForSeconds(time/10)
            elapsedTime += time/10
            t = elapsedTime/time
            t = Mathf.Sin(t * Mathf.PI * 0.5f)
            toggledGraphic.localScale = Vector2.Lerp(startValue, targetScale, t)
        toggledGraphic.localScale = targetScale

        if targetScale == Vector2.zero and toggleActive:
        	toggledGraphic.gameObject.SetActive(false)
        yield