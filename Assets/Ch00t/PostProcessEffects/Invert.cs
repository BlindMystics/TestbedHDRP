using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.Rendering;

[System.Serializable]
[PostProcess(typeof(InvertRenderer), PostProcessEvent.AfterStack, "Ch00t/Invert")]
public sealed class Invert : PostProcessEffectSettings {

}

sealed class InvertRenderer : PostProcessEffectRenderer<Invert> {
    public override void Render(PostProcessRenderContext context) {
        PropertySheet sheet = context.propertySheets.Get(Shader.Find("Hidden/Ch00t/PostProcessing/Invert"));

        CommandBuffer cmd = context.command;
        cmd.BeginSample("Invert");
        cmd.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        cmd.EndSample("Invert");

    }
}
