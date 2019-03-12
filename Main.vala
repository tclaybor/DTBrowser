using Gtk;
using WebKit;

public class DTBrowser : Window {

    private const string TITLE = "DT Browser";
    private const string DEFAULT_URL = "https://google.com/";
    private const string DEFAULT_PROTOCOL = "http";

    private Regex protocol_regex;

    private Entry url_bar;
    private WebView web_view;
    //private Label status_bar;
    private ToolButton back_button;
    private ToolButton forward_button;
    private ToolButton reload_button;

    public DTBrowser () {
        this.title = DTBrowser.TITLE;
        set_default_size (800, 600);

        try {
            this.protocol_regex = new Regex (".*://.*");
        } catch (RegexError e) {
            critical ("%s", e.message);
        }

        create_widgets ();
        connect_signals ();
        this.url_bar.grab_focus ();
    }

    private void create_widgets () {
        var toolbar = new Toolbar ();
        Gtk.Image img = new Gtk.Image.from_icon_name ("go-previous", Gtk.IconSize.SMALL_TOOLBAR);
                  this.back_button = new Gtk.ToolButton (img, null);
        img = new Gtk.Image.from_icon_name ("go-next", Gtk.IconSize.SMALL_TOOLBAR);
                  this.forward_button = new Gtk.ToolButton (img, null);
        img = new Gtk.Image.from_icon_name ("view-refresh", Gtk.IconSize.SMALL_TOOLBAR);
                  this.reload_button = new Gtk.ToolButton (img, null);
        toolbar.add (this.back_button);
        toolbar.add (this.forward_button);
        toolbar.add (this.reload_button);
        this.url_bar = new Entry ();
        this.web_view = new WebView ();
        var scrolled_window = new ScrolledWindow (null, null);
        scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scrolled_window.add (this.web_view);
        //this.status_bar = new Label ("Welcome");
        //this.status_bar.xalign = 0;
        var box = new Box (Gtk.Orientation.VERTICAL, 0);
        box.pack_start (toolbar, false, true, 0);
        box.pack_start (this.url_bar, false, true, 0);
        box.pack_start (scrolled_window, true, true, 0);
        //box.pack_start (this.status_bar, false, true, 0);
        add (box);
    }

    private void connect_signals () {
        this.destroy.connect (Gtk.main_quit);
        this.url_bar.activate.connect (on_activate);
        this.web_view.load_changed.connect ((source, evt) => {
            this.url_bar.text = source.get_uri ();
            this.title = "%s - %s".printf (this.url_bar.text, DTBrowser.TITLE);
            update_buttons ();
        });
        this.back_button.clicked.connect (this.web_view.go_back);
        this.forward_button.clicked.connect (this.web_view.go_forward);
        this.reload_button.clicked.connect (this.web_view.reload);
    }

    private void update_buttons () {
        this.back_button.sensitive = this.web_view.can_go_back ();
        this.forward_button.sensitive = this.web_view.can_go_forward ();
    }

    private void on_activate () {
        var url = this.url_bar.text;
        if (!this.protocol_regex.match (url)) {
            url = "%s://%s".printf (DTBrowser.DEFAULT_PROTOCOL, url);
        }
        this.web_view.load_uri (url);
    }

    public void start () {
        show_all ();
        this.web_view.load_uri (DEFAULT_URL);
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        var browser = new DTBrowser ();
        browser.start ();

        Gtk.main ();

        return 0;
    }
}
