return {
  s("logging-stdout-setup", fmt([[
import logging
import sys

logger = logging.getLogger(__name__)
logging.basicConfig(stream=sys.stdout, level=logging.INFO)
  ]], {}, {delimiters="<>"}))
}
