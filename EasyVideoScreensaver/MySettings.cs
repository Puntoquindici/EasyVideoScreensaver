using System;
using System.Collections.Generic;
using System.IO;
using System.Xml.Serialization;

namespace EasyVideoScreensaver
{ 
    public class MySettings
    {
        public string VideoFilename { get; set; }
        public string StretchMode { get; set; }
        public double Volume { get; set; }
        public Boolean Mute { get; set; }
        public Boolean Resume { get; set; }

        public double ResumePosition { get; set; }

        private static MySettings Defaults()
        {
            return new MySettings
            {
                VideoFilename = "",
                StretchMode = "Fit",
                Mute = false,
                Volume = .5,
                Resume = false,
                ResumePosition = 0
            };
        }

        public void Save(string filename)
        {
            //Write to a temp file, then replace, so an interruption cannot corrupt the settings
            string tmp = filename + ".tmp";
            using (StreamWriter sw = new StreamWriter(tmp))
            {
                XmlSerializer xmls = new XmlSerializer(typeof(MySettings));
                xmls.Serialize(sw, this);
            }
            if (File.Exists(filename))
                File.Replace(tmp, filename, null);
            else
                File.Move(tmp, filename);
        }

        public static MySettings Load(string filename)
        {
            MySettings settings = null;
            if (File.Exists(filename))
            {
                try
                {
                    using (StreamReader sr = new StreamReader(filename))
                    {
                        XmlSerializer xmls = new XmlSerializer(typeof(MySettings));
                        settings = xmls.Deserialize(sr) as MySettings;
                    }
                }
                catch (Exception)
                {
                    //Corrupted or unreadable settings: fall back to defaults
                    settings = null;
                }
            }
            if (settings == null)
                return Defaults();

            //Validate volume
            if (double.IsNaN(settings.Volume) || settings.Volume < 0)
                settings.Volume = 0;
            if (settings.Volume > 1)
                settings.Volume = 1;

            //Validate resume position
            if (double.IsNaN(settings.ResumePosition) || double.IsInfinity(settings.ResumePosition) || settings.ResumePosition < 0)
                settings.ResumePosition = 0;

            //Validate stretch mode
            if (settings.StretchMode != "Fit" && settings.StretchMode != "Fill" && settings.StretchMode != "Center")
                settings.StretchMode = "Fit";

            //Accept only local file paths (no UNC shares, no URLs)
            if (!IsLocalFilePath(settings.VideoFilename))
                settings.VideoFilename = "";

            return settings;
        }

        private static bool IsLocalFilePath(string path)
        {
            if (string.IsNullOrEmpty(path))
                return false;
            try
            {
                Uri uri;
                return Path.IsPathRooted(path)
                    && Uri.TryCreate(path, UriKind.Absolute, out uri)
                    && uri.IsFile && !uri.IsUnc;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}