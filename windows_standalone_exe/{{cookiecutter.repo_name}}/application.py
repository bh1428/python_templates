#!/usr/bin/env python3
"""Application script."""

import logging


def main(divisor: int) -> int:
    """Simple main function with logging and options to generate an exception

    Args:
        divisor: converted to int and then used as a divisor (you can easily
                 trigger an exception with this (e.g. ZeroDivisionError))

    Returns:
        0 to signal that execution has finished successfully
    """
    logger = logging.getLogger(__name__)
    logger.critical("we are in main (CRITICAL)")
    logger.error("we are in main (ERROR)")
    logger.warning("we are in main (WARNING)")
    logger.info("we are in main (INFO)")
    logger.debug("we are in main (DEBUG)")

    # divide: opportunity to trigger a ZeroDivisionError exception
    logger.info("1 / %s = %s", divisor, 1 / divisor)

    return 0
