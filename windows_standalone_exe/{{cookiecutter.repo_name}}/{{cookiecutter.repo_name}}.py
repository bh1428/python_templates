#!/usr/bin/env python3
"""Main script for {{ cookiecutter.repo_name }}"""

import copy
import logging
import logging.config
import os
import pathlib as pl
import sys
import typing as tp

import click
from platformdirs import PlatformDirs

import application

__version__ = "{{ cookiecutter.app_version }}"

# application directoy in %LOCALAPPDATA% will be 'COMPANY\APP_DIR'
COMPANY = "{{ cookiecutter.author_company }}"
LOCAL_APP_DIR = "{{ cookiecutter.repo_name }}"

# logging configuration
LogConfigType = dict[str, tp.Union[tp.Any, dict[str, tp.Union[tp.Any, dict[str, tp.Any]]]]]
LOG_CONFIG: LogConfigType = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "simple": {
            "format": "%(asctime)s.%(msecs)03d %(levelname)s %(message)s",
            "datefmt": "%Y-%m-%d %H:%M:%S",
        },
        "precise": {
            "format": "%(asctime)s.%(msecs)03d %(levelname)s [%(name)s.%(funcName)s(%(lineno)d)] %(message)s",
            "datefmt": "%Y-%m-%d %H:%M:%S",
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "level": "DEBUG",
            "formatter": "simple",
            "stream": "ext://sys.stdout",
        },
        "file": {
            "class": "logging.handlers.TimedRotatingFileHandler",
            "level": "DEBUG",
            "formatter": "precise",
            "filename": "application.log",
            "when": "W6",
            "backupCount": 4,
        },
    },
    "root": {"level": "DEBUG", "handlers": []},
}

LOG_LEVELS = ["CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"]


@click.command()
@click.option("-d", "--divisor", default=1, type=click.INT)
@click.option(
    "--logfile/--no-logfile",
    default=True,
    help="disable logging to a file (default is to console and a logfile)",
)
@click.option(
    "--logdir",
    type=click.Path(exists=True, writable=True),
    help="directory for the logfiles",
)
@click.option("-l", "--loglevel", default="INFO", type=click.Choice(LOG_LEVELS))
@click.version_option(version=__version__, message="%(prog)s V%(version)s")
def click_main(divisor: int, logfile: bool, logdir: str, loglevel: str) -> int:
    """Click template example

    The docstring entered here will be shown as part of the '--help' output.
    """
    # setup logger configuration
    script_name = pl.Path(sys.argv[0]).stem
    log_config = copy.deepcopy(LOG_CONFIG)
    log_config["root"]["level"] = loglevel
    if logfile:
        if logdir is None:
            logdir = PlatformDirs(appname=LOCAL_APP_DIR, appauthor=COMPANY, roaming=False).user_config_path
            if not logdir.exists():
                logdir.mkdir(parents=True)
        log_config["root"]["handlers"] = ["console", "file"]
        log_config["handlers"]["file"]["filename"] = pl.Path(logdir).joinpath(f"{script_name}.log")
    else:
        log_config["root"]["handlers"] = ["console"]
        del log_config["handlers"]["file"]
    logging.config.dictConfig(log_config)

    # initialize logging
    logger = logging.getLogger(__name__)
    logger.info("starting '%s' V%s", pl.Path(sys.argv[0]).name, __version__)
    if os.name == "nt":
        logger.info(
            "running on '%s' as user '%s\\%s'",
            os.environ["COMPUTERNAME"],
            os.environ["USERDOMAIN"],
            os.environ["USERNAME"],
        )
    if logfile:
        logger.info("logging to console and file")
    else:
        logger.info("logging to console only")

    # execute main
    return_code = 0
    try:
        return_code = application.main(divisor)
    except Exception:  # pylint: disable=broad-except
        logger.critical("caught unhandled exception", exc_info=True)
        return_code = 1

    # exit with an informal or an error message
    msg = f"exit with returncode={return_code}"
    if return_code == 0:
        logger.info(msg)
    else:
        logger.error(msg)
    return return_code


if __name__ == "__main__":
    # pylint: disable=pointless-string-statement
    """Default main when called directly as a script.

    When called via this main the name of the script in UPPERCASE will be
    used as an environment prefix for configuration variables, so you can
    enter options via command line arguments or via environment variables.
    For example: when the script is called cli.py you can use a environment
    variable like CLI_LOGDIR to set the directory for logfiles. Note: if you
    do this you should not use quotes (") surrounding paths (the content of
    environment variables can contains spaces).

    The returncode convention is:
      0 - normal exit
      1 - error / uncaught exception
      2 - issue with arguments
    """
    SCRIPT_NAME = pl.Path(__file__).stem.upper()
    try:
        # pylint: disable=no-value-for-parameter, unexpected-keyword-arg
        RETURN_CODE = click_main(standalone_mode=False, auto_envvar_prefix=SCRIPT_NAME)
    except click.ClickException as exc:
        # standalone mode ignores exception: catch them anyway and give meaningful error
        exc.show()
        RETURN_CODE = exc.exit_code
    sys.exit(RETURN_CODE)
