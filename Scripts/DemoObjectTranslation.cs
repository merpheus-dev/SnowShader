using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DemoObjectTranslation : MonoBehaviour
{
    [SerializeField] private float speed = 2;
    void Update()
    {
        transform.position = new Vector3(transform.position.x + Input.GetAxis("Horizontal")*Time.deltaTime*speed, transform.position.y,
            transform.position.z + Input.GetAxis("Vertical")*Time.deltaTime*speed);
        ;
    }
}