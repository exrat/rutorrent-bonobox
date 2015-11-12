plugin.loadLang();

plugin.loadCSS("linklogs");

plugin.onLangLoaded = function()
{
    this.addButtonToToolbar("linklogs", theUILang.linklogs, plugin.optionlink+"('" + plugin.url + "')", "help");
    this.addSeparatorToToolbar("help");
}

plugin.onRemove = function()
{
    this.removeSeparatorFromToolbar("linklogs");
    this.removeButtonFromToolbar("linklogs");
}
