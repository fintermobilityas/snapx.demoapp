using System;
using Avalonia.Media;

namespace demoapp.Styles
{
    /// <summary>
    /// Temp workaround for using fonts in styles
    /// </summary>
    public class RobotoFontFamily : FontFamily
    {
        public RobotoFontFamily()
            : base (new Uri("resm:demoapp.Assets.Fonts?assembly=demoapp"), "Roboto")
        {
        }
    }
}