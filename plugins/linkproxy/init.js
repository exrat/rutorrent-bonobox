plugin.loadLang();

plugin.loadCSS("linkproxy");

plugin.onLangLoaded = function()
{
    this.addButtonToToolbar("linkproxy", theUILang.linkproxy, plugin.optionlink+"('" + plugin.url + "')", "help");
    this.addSeparatorToToolbar("help");
}

plugin.onRemove = function()
{
    this.removeSeparatorFromToolbar("linkproxy");
    this.removeButtonFromToolbar("linkproxy");
}
