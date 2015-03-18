# Pandoc Preview

Run your current file through Pandoc and preview the output within Atom.

Commands:

  * `Pandoc Preview: Show` will run the current buffer through Pandoc and show it in a new pane.

There are three config settings:

  * `pandoc.cmd` which is the pandoc executable. This needs to be on your `PATH`.
  * `pandoc.args` which are the command-line arguments to pandoc, defaults to `-s -S --self-contained`.
  * `pandoc.languages`, a map of Atom grammar names to Pandoc input formats.

## Limitations

  * Only has HTML output at the moment
  * Limited detection of input formats

## Problems with PATH

To find the `pandoc` executable, ideally Atom should be able to find it on your `PATH`. Unfortunately, environment variables are a bit of an issue with GUI applications on OS X. Google it or see [Setting Environment Variables in OS X?](http://stackoverflow.com/questions/135688/setting-environment-variables-in-os-x).

For the `atom` command, you need to make sure Atom is loaded via env (in some older versions of Atom it is not).

    vim `which atom`

If you can find the following, you are fine:

    open -a "$ATOM_PATH/$ATOM_APP_NAME" -n --args --executed-from="$(pwd)" --pid=$$ --path-environment="$PATH" "$@"

If you see the following instead:

    open -a $ATOM_PATH -n --args --executed-from="$(pwd)" --pid=$$ $@

Change it to:

    env open -a $ATOM_PATH -n --args --executed-from="$(pwd)" --pid=$$ $@

Now Atom will have access to `PATH`, and can find your `pandoc` command.
