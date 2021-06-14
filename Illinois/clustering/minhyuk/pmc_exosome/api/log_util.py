"""A logging module for use with elsapy.
    Additional resources:
    * https://github.com/ElsevierDev/elsapy
    * https://dev.elsevier.com
    * https://api.elsevier.com"""

import time, logging
try:
    from pathlib import Path
except ImportError:
    from pathlib2 import Path

## Following adapted from https://docs.python.org/3/howto/logging-cookbook.html

def get_logger(log_dir):
    # TODO: add option to disable logging, without stripping logger out of all modules
    #   - e.g. by simply not writing to file if logging is disabled. See
    #   https://github.com/ElsevierDev/elsapy/issues/26
    # create logger with module name
    logger = logging.getLogger("default-logger")
    logger.setLevel(logging.DEBUG)
    # create log path, if not already there
    logPath = Path(log_dir)
    if not logPath.exists():
        logPath.mkdir()
    # create file handler which logs even debug messages
    fh = logging.FileHandler(f"{log_dir}/api-{str(time.strftime('%m%d%Y'))}.log")
    fh.setLevel(logging.DEBUG)
    # create console handler with a higher log level
    ch = logging.StreamHandler()
    ch.setLevel(logging.ERROR)
    # create formatter and add it to the handlers
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    fh.setFormatter(formatter)
    ch.setFormatter(formatter)
    # add the handlers to the logger
    logger.addHandler(fh)
    logger.addHandler(ch)
    logger.info("Module loaded.")
    return logger