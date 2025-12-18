return {
  s({ trig = "", description = "" }, fmt([[

  ]], {}, {})),
  s("task", fmt([[

  ]], {}, {})),
}
--         t = {
--           description = 'Task',
--           template = string.format([[
-- * TODO [#C] %%?
--   DEADLINE: %%t
--   :PROPERTIES:
--   :OPENED: [%s]
--   :END:
--           ]], timestamp_format),
--           target = files_dir .. "/tasks.org"
--         },
--         r = {
--           description = "Review",
--           template = string.format([[
-- * TODO [#C] %%?
--   DEADLINE: %%t
--   :PROPERTIES:
--   :OPENED: [%s]
--   :END:
--           ]], timestamp_format),
--           target = files_dir .. "/reviews.org",
--         },
--         s = {
--           description = "Self-study / Learning",
--           template = string.format([[
-- * TODO [#C] %%?
--   DEADLINE: %%t
--   :PROPERTIES:
--   :OPENED: [%s]
--   :END:
--           ]], timestamp_format),
--           target = files_dir .. "/learn.org"
--         },
--         f = {
--           description = "Feedback",
--           template = string.format(
--             [[
-- * FEEDBACK [#C] Feedback: %%? :unrefined:feedback:
--   :PROPERTIES:
--   :OPENED: [%s]
--   :END:
--             ]],
--             timestamp_format),
--           target = files_dir .. "/feedback.org"
--         }
--       }
--
