/* This file needs to interact with the yed core. */
#include <yed/plugin.h>

/*
 * Below is a simple implementation of a command that we're going to use to
 * compile this file when you make changes to it.
 */
void recompile_init(int n_args, char **args);

void open_log(int n_args, char **args);

void scroll(int n_args, char **args);

/* This is the entry point for this file when yed loads it. */
int yed_plugin_boot(yed_plugin *self) {
    char *path;

    /*
     * This macro ensures that our init plugin isn't loaded into an
     * incompatible version of yed.
     * All it does is return an error code back to yed if the versions
     * don't look right.
     */
    YED_PLUG_VERSION_CHECK();

    /* This makes the recompile_init function available as a command. */
    yed_plugin_set_command(self, "recompile-init", recompile_init);
    yed_plugin_set_command(self, "blog", open_log);
    yed_plugin_set_command(self, "scroll", scroll);

    YEXE("plugin-load", "yedrc");

    path = get_config_item_path("yedrc");

    YEXE("yedrc-load", path);

    free(path);

    return 0;
}

void recompile_init(int n_args, char **args) {
    char *build_sh_path;
    char  buff[4096];

    build_sh_path = get_config_item_path("build_init.sh");

    snprintf(buff, sizeof(buff), "%s && echo success", build_sh_path);

    free(build_sh_path);

    YEXE("sh", buff);
}

void open_log(int n_args, char **args)
{
    YEXE("buffer", "*log");
}

void scroll(int n_args, char **args)
{
    if (n_args != 1)
    {
        return;
    }
    
    int val = atoi(args[0]);
    if(val > 0)
    {
        for(int i = 0; i < val; i++)
        {
            YEXE("cursor-down");
        }
    }
    
    if(val < 0)
    {
        val = -val;
        for(int i = 0; i < val; i++)
        {
            YEXE("cursor-up");
        }
    }
}
