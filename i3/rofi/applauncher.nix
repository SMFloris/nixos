{mkLiteral}:
{
  "configuration" = {
    "show-icons" = true;
    "display-drun" = "Applications:";
    "display-window" = "Windows: ";
    "drun-display-format" = "\{name\} [<span weight='light' size='small'><i>(\{generic\})</i></span>] ";
    "font" = "";
  };

  "@theme" = "/dev/null";

  "*" = {
    "bg" = mkLiteral "#1E1E2E99";
    "bg-alt" = mkLiteral "#585b7066";
    "bg-selected" = mkLiteral "#31324466";

    "fg" = mkLiteral "#cdd6f4";
    "fg-alt" = mkLiteral "#7f849c";

    "border" = mkLiteral "0";
    "margin" = mkLiteral "0";
    "padding" = mkLiteral "0";
    "spacing" = mkLiteral "0";
  };

  "window" = {
    "width" = mkLiteral "30%";
    "background-color" = mkLiteral "@bg";
  };

  "element" = {
    "padding" = mkLiteral "8 12";
    "background-color" = mkLiteral "transparent";
    "text-color" = mkLiteral "@fg-alt";
  };

  "element selected" = {
    "text-color" = mkLiteral "@fg";
    "background-color" = mkLiteral "@bg-selected";
  };

  "element-text" = {
    "background-color" = mkLiteral "transparent";
    "text-color" = mkLiteral "inherit";
    "vertical-align" = mkLiteral "0.5";
  };

  "element-icon" = {
    "size" = mkLiteral "40";
    "padding" = mkLiteral "0 10 0 0";
    "background-color" = mkLiteral "transparent";
  };

  "entry" = {
    "padding" = mkLiteral "12";
    "background-color" = mkLiteral "@bg-alt";
    "text-color" = mkLiteral "@fg";
  };

  "inputbar" = {
    "children" = mkLiteral "[prompt, entry]";
    "background-color" = mkLiteral "@bg";
  };

  "listview" = {
    "background-color" = mkLiteral "@bg";
    "columns" = mkLiteral "1";
    "lines" = mkLiteral "6";
  };

  "mainbox" = {
    "children" = mkLiteral "[inputbar, listview]";
    "background-color" = mkLiteral "@bg";
  };

  "prompt" = {
    "enabled" = mkLiteral "true";
    "padding" = mkLiteral "12 0 0 12";
    "background-color" = mkLiteral "@bg-alt";
    "text-color" = mkLiteral "@fg";
  };
}

