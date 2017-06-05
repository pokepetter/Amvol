import UnityEngine

public class DerpLerp (MonoBehaviour): 

    public targetVal as Vector3

    public static def Scale(target as Transform, targetValue as Vector3, duration as single):
        lerper as DerpLerp = target.gameObject.AddComponent(DerpLerp)
        if targetValue.x > target.localScale.x or targetValue.y > target.localScale.y: 
            lerper.StartCoroutine(lerper.ScaleUp(targetValue, duration))
        # else:
        #     lerper.StartCoroutine(lerper.ScaleDown(targetValue, duration))

    private def ScaleUp(targetValue as Vector3, duration as single) as IEnumerator:
        elapsedTime = 0f
        t = 0f

        startValue as Vector3 = transform.localScale
        while elapsedTime < duration:
            yield WaitForSeconds(0.02f)
            elapsedTime += 0.02f
            t = elapsedTime/duration
            t = Mathf.Sin(t * Mathf.PI * 0.5f)

            # easeOutElastic
            # p as single = 0.3f
            # t =  1 + 1 * Mathf.Pow(2f, -10f * t) * Mathf.Sin((t) * (2f * Mathf.PI) / p)

            # overshoot as single = 1.25f
            transform.localScale = Vector3.Lerp(startValue, targetValue * 1.1f , t - 0.1f)
        transform.localScale = targetValue

            

        # yield

    private def ScaleDown(targetValue as Vector3, duration as single) as IEnumerator:
        elapsedTime = 0f
        startValue  as Vector3 = transform.localScale
        t = 0f
        t = elapsedTime/duration
        t = Mathf.Sin(t * Mathf.PI * 0.5f)
        transform.localScale = Vector3.Lerp(startValue, targetValue, t)
        yield