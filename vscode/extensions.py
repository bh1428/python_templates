#!/usr/bin/env python3
"""Jinja2 extensions."""

import arrow
from jinja2 import nodes
from jinja2.ext import Extension


class ArrowNowExtension(Extension):
    """Jinja2 Extension for dates and times using Arrow.format."""

    tags = {"arrow_now"}

    def __init__(self, environment):
        """Jinja2 Extension constructor."""
        super().__init__(environment)

        environment.extend(arrow_now_format="YYYY.M.D")

    def _datetime(self, timezone, operator, offset, arrow_now_format):
        d = arrow.now(timezone)

        # parse shift params from offset and include operator
        shift_params = {}
        for param in offset.split(","):
            interval, value = param.split("=")
            shift_params[interval.strip()] = float(operator + value.strip())
        d = d.shift(**shift_params)

        if arrow_now_format is None:
            arrow_now_format = self.environment.arrow_now_format
        return d.format(arrow_now_format)

    def _arrow_now(self, timezone, arrow_now_format):
        if arrow_now_format is None:
            arrow_now_format = self.environment.arrow_now_format
        return arrow.now(timezone).format(arrow_now_format)

    def parse(self, parser):
        """Parse datetime template and add datetime value."""
        lineno = next(parser.stream).lineno

        node = parser.parse_expression()

        if parser.stream.skip_if("comma"):
            arrow_now_format = parser.parse_expression()
        else:
            arrow_now_format = nodes.Const(None)

        if isinstance(node, nodes.Add):
            call_method = self.call_method(
                "_datetime",
                [node.left, nodes.Const("+"), node.right, arrow_now_format],
                lineno=lineno,
            )
        elif isinstance(node, nodes.Sub):
            call_method = self.call_method(
                "_datetime",
                [node.left, nodes.Const("-"), node.right, arrow_now_format],
                lineno=lineno,
            )
        else:
            call_method = self.call_method(
                "_arrow_now",
                [node, arrow_now_format],
                lineno=lineno,
            )
        return nodes.Output([call_method], lineno=lineno)
