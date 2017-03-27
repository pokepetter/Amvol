import UnityEngine

class FollowMouse (MonoBehaviour): 

    private mainCamera as Camera

    # def Awake():
    #     mainCamera = Camera.main

    def Update ():
        # p as Vector2 = mainCamera.ScreenToWorldPoint(Vector2(Input.mousePosition.x, Input.mousePosition.y))
        # transform.localPosition.x = p.x
        # transform.localPosition.y = p.y

        transform.position = Input.mousePosition