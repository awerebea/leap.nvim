local hl = require("leap.highlight")
local opts = require("leap.opts")
local _local_1_ = require("leap.util")
local inc = _local_1_["inc"]
local dec = _local_1_["dec"]
local clamp = _local_1_["clamp"]
local echo = _local_1_["echo"]
local replace_keycodes = _local_1_["replace-keycodes"]
local get_cursor_pos = _local_1_["get-cursor-pos"]
local push_cursor_21 = _local_1_["push-cursor!"]
local get_eq_class_of = _local_1_["get-eq-class-of"]
local __3erepresentative_char = _local_1_["->representative-char"]
local get_input = _local_1_["get-input"]
local get_input_by_keymap = _local_1_["get-input-by-keymap"]
local api = vim.api
local contains_3f = vim.tbl_contains
local empty_3f = vim.tbl_isempty
local map = vim.tbl_map
local _local_2_ = math
local abs = _local_2_["abs"]
local ceil = _local_2_["ceil"]
local max = _local_2_["max"]
local min = _local_2_["min"]
local pow = _local_2_["pow"]
local function exec_user_autocmds(pattern)
  return api.nvim_exec_autocmds("User", {pattern = pattern, modeline = false})
end
local function handle_interrupted_change_op_21()
  local seq
  local function _3_()
    if (vim.fn.col(".") > 1) then
      return "<RIGHT>"
    else
      return ""
    end
  end
  seq = ("<C-\\><C-G>" .. _3_())
  return api.nvim_feedkeys(replace_keycodes(seq), "n", true)
end
local function set_dot_repeat_2a()
  local op = vim.v.operator
  local cmd = replace_keycodes("<cmd>lua require'leap'.leap { dot_repeat = true }<cr>")
  local change
  if (op == "c") then
    change = replace_keycodes("<c-r>.<esc>")
  else
    change = nil
  end
  local seq = (op .. cmd .. (change or ""))
  pcall(vim.fn["repeat#setreg"], seq, vim.v.register)
  return pcall(vim.fn["repeat#set"], seq, -1)
end
local function eq_classes__3emembership_lookup(eqcls)
  local res = {}
  for _, eqcl in ipairs(eqcls) do
    local eqcl_2a
    if (type(eqcl) == "string") then
      eqcl_2a = vim.fn.split(eqcl, "\\zs")
    else
      eqcl_2a = eqcl
    end
    for _0, ch in ipairs(eqcl_2a) do
      res[ch] = eqcl_2a
    end
  end
  return res
end
local function set_autojump(targets, force_noautojump_3f)
  targets["autojump?"] = (not (force_noautojump_3f or empty_3f(opts.safe_labels)) and (empty_3f(opts.labels) or (#opts.safe_labels >= dec(#targets))))
  return nil
end
local function attach_label_set(targets)
  if empty_3f(opts.labels) then
    targets["label-set"] = opts.safe_labels
  elseif empty_3f(opts.safe_labels) then
    targets["label-set"] = opts.labels
  elseif targets["autojump?"] then
    targets["label-set"] = opts.safe_labels
  else
    targets["label-set"] = opts.labels
  end
  return nil
end
local function set_labels(targets, multi_select_3f)
  if ((#targets > 1) or multi_select_3f) then
    local _local_7_ = targets
    local autojump_3f = _local_7_["autojump?"]
    local label_set = _local_7_["label-set"]
    for i, target in ipairs(targets) do
      local i_2a
      if autojump_3f then
        i_2a = dec(i)
      else
        i_2a = i
      end
      if (i_2a > 0) then
        local _9_ = (i_2a % #label_set)
        if (_9_ == 0) then
          target.label = label_set[#label_set]
        elseif (nil ~= _9_) then
          local n = _9_
          target.label = label_set[n]
        else
          target.label = nil
        end
      else
      end
    end
    return nil
  else
    return nil
  end
end
local function set_label_states(targets, _13_)
  local _arg_14_ = _13_
  local group_offset = _arg_14_["group-offset"]
  local _7clabel_set_7c = #targets["label-set"]
  local offset = (group_offset * _7clabel_set_7c)
  local primary_start
  local function _15_()
    if targets["autojump?"] then
      return 2
    else
      return 1
    end
  end
  primary_start = (offset + _15_())
  local primary_end = (primary_start + dec(_7clabel_set_7c))
  local secondary_start = inc(primary_end)
  local secondary_end = (primary_end + _7clabel_set_7c)
  for i, target in ipairs(targets) do
    if (target.label and (target["label-state"] ~= "selected")) then
      if (function(_16_,_17_,_18_) return (_16_ <= _17_) and (_17_ <= _18_) end)(primary_start,i,primary_end) then
        target["label-state"] = "active-primary"
      elseif (function(_19_,_20_,_21_) return (_19_ <= _20_) and (_20_ <= _21_) end)(secondary_start,i,secondary_end) then
        target["label-state"] = "active-secondary"
      elseif (i > secondary_end) then
        target["label-state"] = "inactive"
      else
        target["label-state"] = nil
      end
    else
    end
  end
  return nil
end
local function populate_sublists(targets)
  local function _24_(self, ch)
    return rawget(self, __3erepresentative_char(ch))
  end
  local function _25_(self, ch, sublist)
    return rawset(self, __3erepresentative_char(ch), sublist)
  end
  targets.sublists = setmetatable({}, {__index = _24_, __newindex = _25_})
  for _, _26_ in ipairs(targets) do
    local _each_27_ = _26_
    local _each_28_ = _each_27_["chars"]
    local _0 = _each_28_[1]
    local ch2 = _each_28_[2]
    local target = _each_27_
    local ch20 = (ch2 or "\n")
    if not targets.sublists[ch20] then
      targets.sublists[ch20] = {}
    else
    end
    table.insert(targets.sublists[ch20], target)
  end
  return nil
end
local function set_initial_label_states(targets)
  for _, sublist in pairs(targets.sublists) do
    set_label_states(sublist, {["group-offset"] = 0})
  end
  return nil
end
local function get_label_offset(target)
  local _let_30_ = target
  local _let_31_ = _let_30_["chars"]
  local ch1 = _let_31_[1]
  local ch2 = _let_31_[2]
  if target["empty-line?"] then
    return 0
  elseif target["edge-pos?"] then
    return ch1:len()
  else
    return (ch1:len() + ch2:len())
  end
end
local function set_beacon_for_labeled(target, _33_)
  local _arg_34_ = _33_
  local user_given_targets_3f = _arg_34_["user-given-targets?"]
  local aot_3f = _arg_34_["aot?"]
  local offset
  if aot_3f then
    offset = get_label_offset(target)
  else
    offset = 0
  end
  local pad
  if (user_given_targets_3f or aot_3f) then
    pad = ""
  else
    pad = " "
  end
  local label = (opts.substitute_chars[target.label] or target.label)
  local text = (label .. pad)
  local virttext
  do
    local _37_ = target["label-state"]
    if (_37_ == "selected") then
      virttext = {{text, hl.group["label-selected"]}}
    elseif (_37_ == "active-primary") then
      virttext = {{text, hl.group["label-primary"]}}
    elseif (_37_ == "active-secondary") then
      virttext = {{text, hl.group["label-secondary"]}}
    elseif (_37_ == "inactive") then
      if (aot_3f and not opts.highlight_unlabeled_phase_one_targets) then
        virttext = {{(" " .. pad), hl.group["label-secondary"]}}
      elseif "else" then
        virttext = nil
      else
        virttext = nil
      end
    else
      virttext = nil
    end
  end
  if virttext then
    target.beacon = {offset, virttext}
  else
    target.beacon = nil
  end
  return nil
end
local function set_beacon_to_match_hl(target)
  local virttext
  local function _41_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  virttext = table.concat(map(_41_, target.chars))
  target.beacon = {0, {{virttext, hl.group.match}}}
  return nil
end
local function set_beacon_to_empty_label(target)
  target["beacon"][2][1][1] = " "
  return nil
end
local function resolve_conflicts(targets)
  local pos_unlabeled_match = {}
  local pos_labeled_match = {}
  local pos_label = {}
  for _, target in ipairs(targets) do
    if not target["empty-line?"] then
      local _local_42_ = target.wininfo
      local bufnr = _local_42_["bufnr"]
      local winid = _local_42_["winid"]
      local _local_43_ = target.pos
      local lnum = _local_43_[1]
      local col = _local_43_[2]
      local col_ch2 = (col + string.len(target.chars[1]))
      if (target.label and target.beacon) then
        local label_offset = target.beacon[1]
        local col_label = (col + label_offset)
        local shifted_label_3f = (col_label == col_ch2)
        do
          local _44_ = pos_unlabeled_match[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col_label)]
          if (nil ~= _44_) then
            local other = _44_
            target.beacon = nil
            set_beacon_to_match_hl(other)
          else
          end
        end
        if shifted_label_3f then
          local _46_ = pos_unlabeled_match[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col)]
          if (nil ~= _46_) then
            local other = _46_
            set_beacon_to_match_hl(other)
          else
          end
        else
        end
        do
          local _49_ = pos_label[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col_label)]
          if (nil ~= _49_) then
            local other = _49_
            target.beacon = nil
            set_beacon_to_empty_label(other)
          else
          end
        end
        pos_label[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col_label)] = target
        pos_labeled_match[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col)] = target
        if not shifted_label_3f then
          pos_labeled_match[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col_ch2)] = target
        else
        end
      elseif not target.label then
        for _0, key in ipairs({(bufnr .. " " .. winid .. " " .. lnum .. " " .. col), (bufnr .. " " .. winid .. " " .. lnum .. " " .. col_ch2)}) do
          pos_unlabeled_match[key] = target
          local _52_ = pos_label[key]
          if (nil ~= _52_) then
            local other = _52_
            other.beacon = nil
            set_beacon_to_match_hl(target)
          else
          end
        end
        local col_after = (col_ch2 + string.len(target.chars[2]))
        local _54_ = pos_label[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col_after)]
        if (nil ~= _54_) then
          local other = _54_
          set_beacon_to_match_hl(target)
        else
        end
      else
      end
    else
    end
  end
  return nil
end
local function set_beacons(targets, _58_)
  local _arg_59_ = _58_
  local no_labels_3f = _arg_59_["no-labels?"]
  local user_given_targets_3f = _arg_59_["user-given-targets?"]
  local aot_3f = _arg_59_["aot?"]
  if (no_labels_3f and targets[1].chars) then
    for _, target in ipairs(targets) do
      set_beacon_to_match_hl(target)
    end
    return nil
  else
    for _, target in ipairs(targets) do
      if target.label then
        set_beacon_for_labeled(target, {["user-given-targets?"] = user_given_targets_3f, ["aot?"] = aot_3f})
      elseif (aot_3f and opts.highlight_unlabeled_phase_one_targets) then
        set_beacon_to_match_hl(target)
      else
      end
    end
    if aot_3f then
      return resolve_conflicts(targets)
    else
      return nil
    end
  end
end
local function light_up_beacons(targets, _3fstart, _3fend)
  for i = (_3fstart or 1), (_3fend or #targets) do
    local target = targets[i]
    local _63_ = target.beacon
    if ((_G.type(_63_) == "table") and (nil ~= (_63_)[1]) and (nil ~= (_63_)[2])) then
      local offset = (_63_)[1]
      local virttext = (_63_)[2]
      local bufnr = target.wininfo.bufnr
      local _let_64_ = map(dec, target.pos)
      local lnum = _let_64_[1]
      local col = _let_64_[2]
      local id = api.nvim_buf_set_extmark(bufnr, hl.ns, lnum, (col + offset), {virt_text = virttext, virt_text_pos = "overlay", hl_mode = "combine", priority = hl.priority.label})
      table.insert(hl.extmarks, {bufnr, id})
    else
    end
  end
  return nil
end
local state = {args = nil, source_window = nil, ["repeat"] = {in1 = nil, in2 = nil}, dot_repeat = {in1 = nil, in2 = nil, target_idx = nil, backward = nil, inclusive_op = nil, offset = nil}, saved_editor_opts = {}}
local function leap(kwargs)
  local _local_66_ = kwargs
  local dot_repeat_3f = _local_66_["dot_repeat"]
  local target_windows = _local_66_["target_windows"]
  local user_given_opts = _local_66_["opts"]
  local user_given_targets = _local_66_["targets"]
  local user_given_action = _local_66_["action"]
  local multi_select_3f = _local_66_["multiselect"]
  local function _68_()
    if dot_repeat_3f then
      return state.dot_repeat
    else
      return kwargs
    end
  end
  local _local_67_ = _68_()
  local backward_3f = _local_67_["backward"]
  local match_last_overlapping_3f = _local_67_["match_last_overlapping"]
  local inclusive_op_3f = _local_67_["inclusive_op"]
  local offset = _local_67_["offset"]
  opts.current_call = (user_given_opts or {})
  do
    local _69_ = opts.current_call.equivalence_classes
    if (nil ~= _69_) then
      opts.current_call.eq_class_of = eq_classes__3emembership_lookup(_69_)
    else
      opts.current_call.eq_class_of = _69_
    end
  end
  local directional_3f = not target_windows
  local empty_label_lists_3f = (empty_3f(opts.labels) and empty_3f(opts.safe_labels))
  if (not directional_3f and empty_label_lists_3f) then
    echo("no labels to use")
    return
  else
  end
  if (target_windows and empty_3f(target_windows)) then
    echo("no targetable windows")
    return
  else
  end
  if (multi_select_3f and not user_given_action) then
    echo("error: multiselect mode requires user-provided `action` callback")
    return
  else
  end
  local curr_winid = vim.fn.win_getid()
  state.args = kwargs
  state.source_window = curr_winid
  local _3ftarget_windows = target_windows
  local hl_affected_windows
  do
    local tbl_17_auto = {curr_winid}
    local i_18_auto = #tbl_17_auto
    for _, winid in ipairs((_3ftarget_windows or {})) do
      local val_19_auto = winid
      if (nil ~= val_19_auto) then
        i_18_auto = (i_18_auto + 1)
        do end (tbl_17_auto)[i_18_auto] = val_19_auto
      else
      end
    end
    hl_affected_windows = tbl_17_auto
  end
  local mode = api.nvim_get_mode().mode
  local op_mode_3f = mode:match("o")
  local change_op_3f = (op_mode_3f and (vim.v.operator == "c"))
  local dot_repeatable_op_3f = (op_mode_3f and directional_3f and (vim.v.operator ~= "y"))
  local count
  if not directional_3f then
    count = nil
  elseif (vim.v.count == 0) then
    if (op_mode_3f and empty_label_lists_3f) then
      count = 1
    else
      count = nil
    end
  else
    count = vim.v.count
  end
  local max_phase_one_targets = (opts.max_phase_one_targets or math.huge)
  local user_given_targets_3f = user_given_targets
  local prompt = {str = ">"}
  local spec_keys
  do
    local function __index(_, k)
      local _77_ = opts.special_keys[k]
      if (nil ~= _77_) then
        local v = _77_
        if ((k == "next_target") or (k == "prev_target")) then
          local _78_ = type(v)
          if (_78_ == "table") then
            local tbl_17_auto = {}
            local i_18_auto = #tbl_17_auto
            for _0, str in ipairs(v) do
              local val_19_auto = replace_keycodes(str)
              if (nil ~= val_19_auto) then
                i_18_auto = (i_18_auto + 1)
                do end (tbl_17_auto)[i_18_auto] = val_19_auto
              else
              end
            end
            return tbl_17_auto
          elseif (_78_ == "string") then
            return {replace_keycodes(v)}
          else
            return nil
          end
        else
          return replace_keycodes(v)
        end
      else
        return nil
      end
    end
    spec_keys = setmetatable({}, {__index = __index})
  end
  local vars = {["aot?"] = not ((max_phase_one_targets == 0) or count or empty_label_lists_3f or multi_select_3f or user_given_targets_3f), ["curr-idx"] = 0, errmsg = nil}
  local function get_user_given_targets(targets)
    local targets_2a
    if (type(targets) == "function") then
      targets_2a = targets()
    else
      targets_2a = targets
    end
    if (targets_2a and (#targets_2a > 0)) then
      local wininfo = vim.fn.getwininfo(curr_winid)[1]
      if not (targets_2a)[1].wininfo then
        for _, t in ipairs(targets_2a) do
          t.wininfo = wininfo
        end
      else
      end
      return targets_2a
    else
      vars.errmsg = "no targets"
      return nil
    end
  end
  local function expand_to_equivalence_class(_in)
    local chars = get_eq_class_of(_in)
    if chars then
      for i, ch in ipairs(chars) do
        if (ch == "\n") then
          chars[i] = "\\n"
        elseif (ch == "\\") then
          chars[i] = "\\\\"
        else
        end
      end
      return ("\\(" .. table.concat(chars, "\\|") .. "\\)")
    else
      return nil
    end
  end
  local function prepare_pattern(in1, _3fin2)
    local pat1 = (expand_to_equivalence_class(in1) or in1:gsub("\\", "\\\\"))
    local pat2
    local function _88_()
      local _89_ = _3fin2
      if (nil ~= _89_) then
        return expand_to_equivalence_class(_89_)
      else
        return _89_
      end
    end
    pat2 = (_88_() or _3fin2 or "\\_.")
    local pat
    if (pat1:match("\\n") and (not _3fin2 or pat2:match("\\n"))) then
      pat = (pat1 .. pat2 .. "\\|\\^\\n")
    else
      pat = (pat1 .. pat2)
    end
    local function _92_()
      if opts.case_sensitive then
        return "\\C"
      else
        return "\\c"
      end
    end
    return ("\\V" .. _92_() .. pat)
  end
  local function get_targets(in1, _3fin2)
    local search = require("leap.search")
    local pattern = prepare_pattern(in1, _3fin2)
    local kwargs0 = {["backward?"] = backward_3f, ["match-last-overlapping?"] = match_last_overlapping_3f, ["target-windows"] = _3ftarget_windows}
    local targets = search["get-targets"](pattern, kwargs0)
    local function _93_()
      vars.errmsg = ("not found: " .. in1 .. (_3fin2 or ""))
      return nil
    end
    return (targets or _93_())
  end
  local function prepare_targets(targets)
    local funny_edge_case_3f
    local function _94_()
      local _95_ = targets
      if ((_G.type(_95_) == "table") and ((_G.type((_95_)[1]) == "table") and ((_G.type(((_95_)[1]).pos) == "table") and (nil ~= (((_95_)[1]).pos)[1]) and (nil ~= (((_95_)[1]).pos)[2]))) and ((_G.type((_95_)[2]) == "table") and ((_G.type(((_95_)[2]).pos) == "table") and (nil ~= (((_95_)[2]).pos)[1]) and (nil ~= (((_95_)[2]).pos)[2])))) then
        local l1 = (((_95_)[1]).pos)[1]
        local c1 = (((_95_)[1]).pos)[2]
        local l2 = (((_95_)[2]).pos)[1]
        local c2 = (((_95_)[2]).pos)[2]
        return ((l1 == l2) and (c1 == (c2 + 2)))
      else
        return nil
      end
    end
    funny_edge_case_3f = (backward_3f and _94_())
    local force_noautojump_3f = (op_mode_3f or multi_select_3f or not directional_3f or user_given_action or funny_edge_case_3f)
    set_autojump(targets, force_noautojump_3f)
    attach_label_set(targets)
    set_labels(targets, multi_select_3f)
    return targets
  end
  local function get_target_with_active_primary_label(sublist, input)
    local res = {}
    for idx, _97_ in ipairs(sublist) do
      local _each_98_ = _97_
      local label = _each_98_["label"]
      local label_state = _each_98_["label-state"]
      local target = _each_98_
      if (next(res) or (label_state == "inactive")) then break end
      if ((label == input) and (label_state == "active-primary")) then
        res = {idx, target}
      else
      end
    end
    return res
  end
  local function update_repeat_state(state_2a)
    if not user_given_targets_3f then
      state["repeat"] = state_2a
      return nil
    else
      return nil
    end
  end
  local function set_dot_repeat(in1, in2, target_idx)
    if (dot_repeatable_op_3f and not (dot_repeat_3f or (type(user_given_targets) == "table"))) then
      local _101_
      if user_given_targets then
        _101_ = {callback = user_given_targets}
      else
        _101_ = {in1 = in1, in2 = in2}
      end
      state.dot_repeat = vim.tbl_extend("error", _101_, {target_idx = target_idx, offset = offset, backward = backward_3f, inclusive_op = inclusive_op_3f})
      return set_dot_repeat_2a()
    else
      return nil
    end
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _104_(target)
      local jump = require("leap.jump")
      jump["jump-to!"](target.pos, {winid = target.wininfo.winid, ["add-to-jumplist?"] = first_jump_3f, mode = mode, offset = offset, ["backward?"] = backward_3f, ["inclusive-op?"] = inclusive_op_3f})
      first_jump_3f = false
      return nil
    end
    jump_to_21 = _104_
  end
  local function get_number_of_highlighted_targets()
    local _105_ = opts.max_highlighted_traversal_targets
    if (nil ~= _105_) then
      local group_size = _105_
      local consumed = (dec(vars["curr-idx"]) % group_size)
      local remaining = (group_size - consumed)
      if (remaining == 1) then
        return inc(group_size)
      elseif (remaining == 0) then
        return group_size
      else
        return remaining
      end
    else
      return nil
    end
  end
  local function get_highlighted_idx_range(targets, no_labels_3f)
    if (no_labels_3f and (opts.max_highlighted_traversal_targets == 0)) then
      return 0, -1
    else
      local start = inc(vars["curr-idx"])
      local _end
      if no_labels_3f then
        local _108_ = get_number_of_highlighted_targets()
        if (nil ~= _108_) then
          local _109_ = (_108_ + dec(start))
          if (nil ~= _109_) then
            _end = min(_109_, #targets)
          else
            _end = _109_
          end
        else
          _end = _108_
        end
      else
        _end = nil
      end
      return start, _end
    end
  end
  local function get_first_pattern_input()
    do
      hl:cleanup(hl_affected_windows)
      if not count then
        hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
      else
      end
      do
        echo("")
      end
      hl["highlight-cursor"](hl)
      vim.cmd("redraw")
    end
    local _115_ = get_input_by_keymap(prompt)
    if (_115_ == spec_keys.repeat_search) then
      if state["repeat"].in1 then
        vars["aot?"] = false
        return state["repeat"].in1, state["repeat"].in2
      else
        vars.errmsg = "no previous search"
        return nil
      end
    elseif (nil ~= _115_) then
      local in1 = _115_
      return in1
    else
      return nil
    end
  end
  local function get_second_pattern_input(targets)
    if (#targets <= max_phase_one_targets) then
      hl:cleanup(hl_affected_windows)
      if not count then
        hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
      else
      end
      do
        light_up_beacons(targets)
      end
      hl["highlight-cursor"](hl)
      vim.cmd("redraw")
    else
    end
    return get_input_by_keymap(prompt)
  end
  local function get_full_pattern_input()
    local _120_, _121_ = get_first_pattern_input()
    if ((nil ~= _120_) and (nil ~= _121_)) then
      local in1 = _120_
      local in2 = _121_
      return in1, in2
    elseif ((nil ~= _120_) and (_121_ == nil)) then
      local in1 = _120_
      local _122_ = get_input_by_keymap(prompt)
      if (nil ~= _122_) then
        local in2 = _122_
        return in1, in2
      else
        return nil
      end
    else
      return nil
    end
  end
  local function post_pattern_input_loop(targets, _3fgroup_offset, first_invoc_3f)
    local _7cgroups_7c
    if not targets["label-set"] then
      _7cgroups_7c = 0
    else
      _7cgroups_7c = ceil((#targets / #targets["label-set"]))
    end
    local function display(group_offset)
      local no_labels_3f = empty_label_lists_3f
      if targets["label-set"] then
        set_label_states(targets, {["group-offset"] = group_offset})
      else
      end
      set_beacons(targets, {["aot?"] = vars["aot?"], ["no-labels?"] = no_labels_3f, ["user-given-targets?"] = user_given_targets_3f})
      hl:cleanup(hl_affected_windows)
      if not count then
        hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
      else
      end
      do
        local start, _end = get_highlighted_idx_range(targets, no_labels_3f)
        light_up_beacons(targets, start, _end)
      end
      hl["highlight-cursor"](hl)
      return vim.cmd("redraw")
    end
    local function loop(group_offset, first_invoc_3f0)
      display(group_offset)
      local _128_ = get_input()
      if (nil ~= _128_) then
        local input = _128_
        if ((1 < _7cgroups_7c) and ((input == spec_keys.next_group) or ((input == spec_keys.prev_group) and not first_invoc_3f0))) then
          local inc_2fdec
          if (input == spec_keys.next_group) then
            inc_2fdec = inc
          else
            inc_2fdec = dec
          end
          local max_offset = dec(_7cgroups_7c)
          local group_offset_2a = clamp(inc_2fdec(group_offset), 0, max_offset)
          return loop(group_offset_2a, false)
        else
          return input, group_offset
        end
      else
        return nil
      end
    end
    return loop((_3fgroup_offset or 0), (first_invoc_3f ~= false))
  end
  local multi_select_loop
  do
    local selection = {}
    local group_offset = 0
    local first_invoc_3f = true
    local function loop(targets)
      local _132_, _133_ = post_pattern_input_loop(targets, group_offset, first_invoc_3f)
      if (_132_ == spec_keys.multi_accept) then
        if not empty_3f(selection) then
          return selection
        else
          return loop(targets)
        end
      elseif (_132_ == spec_keys.multi_revert) then
        do
          local _135_ = table.remove(selection)
          if (nil ~= _135_) then
            _135_["label-state"] = nil
          else
          end
        end
        return loop(targets)
      elseif ((nil ~= _132_) and (nil ~= _133_)) then
        local _in = _132_
        local group_offset_2a = _133_
        group_offset = group_offset_2a
        first_invoc_3f = false
        do
          local _137_ = get_target_with_active_primary_label(targets, _in)
          if ((_G.type(_137_) == "table") and true and (nil ~= (_137_)[2])) then
            local _ = (_137_)[1]
            local target = (_137_)[2]
            if not contains_3f(selection, target) then
              table.insert(selection, target)
              target["label-state"] = "selected"
            else
            end
          else
          end
        end
        return loop(targets)
      else
        return nil
      end
    end
    multi_select_loop = loop
  end
  local function traversal_loop(targets, start_idx, _141_)
    local _arg_142_ = _141_
    local no_labels_3f = _arg_142_["no-labels?"]
    local function on_first_invoc()
      if no_labels_3f then
        for _, t in ipairs(targets) do
          t["label-state"] = "inactive"
        end
        return nil
      elseif not empty_3f(opts.safe_labels) then
        local last_labeled = inc(#opts.safe_labels)
        for i = inc(last_labeled), #targets do
          local _143_ = targets[i]
          _143_["label"] = nil
          _143_["beacon"] = nil
        end
        return nil
      else
        return nil
      end
    end
    local function display()
      set_beacons(targets, {["no-labels?"] = no_labels_3f, ["aot?"] = vars["aot?"], ["user-given-targets?"] = user_given_targets_3f})
      hl:cleanup(hl_affected_windows)
      if not count then
        hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
      else
      end
      do
        local start, _end = get_highlighted_idx_range(targets, no_labels_3f)
        light_up_beacons(targets, start, _end)
      end
      hl["highlight-cursor"](hl)
      return vim.cmd("redraw")
    end
    local function get_new_idx(idx, _in)
      if contains_3f(spec_keys.next_target, _in) then
        return min(inc(idx), #targets)
      elseif contains_3f(spec_keys.prev_target, _in) then
        return max(dec(idx), 1)
      else
        return nil
      end
    end
    local function loop(idx, first_invoc_3f)
      if first_invoc_3f then
        on_first_invoc()
      else
      end
      vars["curr-idx"] = idx
      display()
      local _148_ = get_input()
      if (nil ~= _148_) then
        local _in = _148_
        local _149_ = get_new_idx(idx, _in)
        if (nil ~= _149_) then
          local new_idx = _149_
          do
            local _150_
            do
              local t_151_ = targets
              if (nil ~= t_151_) then
                t_151_ = (t_151_)[new_idx]
              else
              end
              if (nil ~= t_151_) then
                t_151_ = (t_151_).chars
              else
              end
              if (nil ~= t_151_) then
                t_151_ = (t_151_)[2]
              else
              end
              _150_ = t_151_
            end
            if (nil ~= _150_) then
              local ch2 = _150_
              state["repeat"].in2 = ch2
            else
            end
          end
          jump_to_21(targets[new_idx])
          return loop(new_idx, false)
        elseif true then
          local _ = _149_
          local _156_ = get_target_with_active_primary_label(targets, _in)
          if ((_G.type(_156_) == "table") and true and (nil ~= (_156_)[2])) then
            local _0 = (_156_)[1]
            local target = (_156_)[2]
            return jump_to_21(target)
          elseif true then
            local _0 = _156_
            return vim.fn.feedkeys(_in, "i")
          else
            return nil
          end
        else
          return nil
        end
      else
        return nil
      end
    end
    return loop(start_idx, true)
  end
  local do_action = (user_given_action or jump_to_21)
  exec_user_autocmds("LeapEnter")
  local in1, _3fin2 = nil, nil
  if dot_repeat_3f then
    if state.dot_repeat.callback then
      in1, _3fin2 = true, true
    else
      in1, _3fin2 = state.dot_repeat.in1, state.dot_repeat.in2
    end
  elseif user_given_targets_3f then
    in1, _3fin2 = true, true
  elseif vars["aot?"] then
    in1, _3fin2 = get_first_pattern_input()
  else
    in1, _3fin2 = get_full_pattern_input()
  end
  if not in1 then
    if change_op_3f then
      handle_interrupted_change_op_21()
    else
    end
    if vars.errmsg then
      echo(vars.errmsg)
    else
    end
    hl:cleanup(hl_affected_windows)
    exec_user_autocmds("LeapLeave")
    return
  else
  end
  local targets
  if (dot_repeat_3f and state.dot_repeat.callback) then
    targets = get_user_given_targets(state.dot_repeat.callback)
  elseif user_given_targets_3f then
    targets = get_user_given_targets(user_given_targets)
  else
    targets = get_targets(in1, _3fin2)
  end
  if not targets then
    if change_op_3f then
      handle_interrupted_change_op_21()
    else
    end
    if vars.errmsg then
      echo(vars.errmsg)
    else
    end
    hl:cleanup(hl_affected_windows)
    exec_user_autocmds("LeapLeave")
    return
  else
  end
  if dot_repeat_3f then
    local _169_ = targets[state.dot_repeat.target_idx]
    if (nil ~= _169_) then
      local target = _169_
      do_action(target)
      hl:cleanup(hl_affected_windows)
      exec_user_autocmds("LeapLeave")
      return
    elseif true then
      local _ = _169_
      if change_op_3f then
        handle_interrupted_change_op_21()
      else
      end
      if vars.errmsg then
        echo(vars.errmsg)
      else
      end
      hl:cleanup(hl_affected_windows)
      exec_user_autocmds("LeapLeave")
      return
    else
    end
  else
  end
  if _3fin2 then
    if empty_label_lists_3f then
      targets["autojump?"] = true
    else
      prepare_targets(targets)
    end
  else
    if (#targets > max_phase_one_targets) then
      vars["aot?"] = false
    else
    end
    populate_sublists(targets)
    for _, sublist in pairs(targets.sublists) do
      prepare_targets(sublist)
    end
    set_initial_label_states(targets)
    set_beacons(targets, {["aot?"] = vars["aot?"]})
  end
  local in2 = (_3fin2 or get_second_pattern_input(targets))
  if not in2 then
    if change_op_3f then
      handle_interrupted_change_op_21()
    else
    end
    if vars.errmsg then
      echo(vars.errmsg)
    else
    end
    hl:cleanup(hl_affected_windows)
    exec_user_autocmds("LeapLeave")
    return
  else
  end
  if (in2 == spec_keys.next_phase_one_target) then
    local first = targets[1]
    local in2_2a = first.chars[2]
    update_repeat_state({in1 = in1, in2 = in2_2a})
    do_action(first)
    if ((#targets == 1) or op_mode_3f or not directional_3f or user_given_action) then
      set_dot_repeat(in1, in2_2a, 1)
    else
      traversal_loop(targets, 1, {["no-labels?"] = true})
    end
    hl:cleanup(hl_affected_windows)
    exec_user_autocmds("LeapLeave")
    return
  else
  end
  update_repeat_state({in1 = in1, in2 = in2})
  local targets_2a
  if targets.sublists then
    targets_2a = targets.sublists[in2]
  else
    targets_2a = targets
  end
  if not targets_2a then
    vars.errmsg = ("not found: " .. in1 .. in2)
    if change_op_3f then
      handle_interrupted_change_op_21()
    else
    end
    if vars.errmsg then
      echo(vars.errmsg)
    else
    end
    hl:cleanup(hl_affected_windows)
    exec_user_autocmds("LeapLeave")
    return
  else
  end
  if multi_select_3f then
    do
      local _186_ = multi_select_loop(targets_2a)
      if (nil ~= _186_) then
        local targets_2a_2a = _186_
        do
          hl:cleanup(hl_affected_windows)
          if not count then
            hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
          else
          end
          do
            light_up_beacons(targets_2a_2a)
          end
          hl["highlight-cursor"](hl)
          vim.cmd("redraw")
        end
        do_action(targets_2a_2a)
      else
      end
    end
    hl:cleanup(hl_affected_windows)
    exec_user_autocmds("LeapLeave")
    return
  else
  end
  if count then
    if (count > #targets_2a) then
      if change_op_3f then
        handle_interrupted_change_op_21()
      else
      end
      if vars.errmsg then
        echo(vars.errmsg)
      else
      end
      hl:cleanup(hl_affected_windows)
      exec_user_autocmds("LeapLeave")
      return
    else
      set_dot_repeat(in1, in2, count)
      do_action((targets_2a)[count])
      hl:cleanup(hl_affected_windows)
      exec_user_autocmds("LeapLeave")
      return
    end
  elseif (#targets_2a == 1) then
    set_dot_repeat(in1, in2, 1)
    do_action((targets_2a)[1])
    hl:cleanup(hl_affected_windows)
    exec_user_autocmds("LeapLeave")
    return
  else
  end
  if targets_2a["autojump?"] then
    vars["curr-idx"] = 1
    do_action((targets_2a)[1])
  else
  end
  local in_final = post_pattern_input_loop(targets_2a)
  if not in_final then
    if change_op_3f then
      handle_interrupted_change_op_21()
    else
    end
    if vars.errmsg then
      echo(vars.errmsg)
    else
    end
    hl:cleanup(hl_affected_windows)
    exec_user_autocmds("LeapLeave")
    return
  else
  end
  if contains_3f(spec_keys.next_target, in_final) then
    if (op_mode_3f or not directional_3f or user_given_action) then
      set_dot_repeat(in1, in2, 1)
      do_action((targets_2a)[1])
      hl:cleanup(hl_affected_windows)
      exec_user_autocmds("LeapLeave")
      return
    else
      local new_idx = inc(vars["curr-idx"])
      do_action((targets_2a)[new_idx])
      traversal_loop(targets_2a, new_idx, {["no-labels?"] = (empty_label_lists_3f or not targets_2a["autojump?"])})
      hl:cleanup(hl_affected_windows)
      exec_user_autocmds("LeapLeave")
      return
    end
  else
  end
  local _local_200_ = get_target_with_active_primary_label(targets_2a, in_final)
  local idx = _local_200_[1]
  local _ = _local_200_[2]
  if idx then
    set_dot_repeat(in1, in2, idx)
    do_action((targets_2a)[idx])
    hl:cleanup(hl_affected_windows)
    exec_user_autocmds("LeapLeave")
    return
  elseif targets_2a["autojump?"] then
    vim.fn.feedkeys(in_final, "i")
    hl:cleanup(hl_affected_windows)
    exec_user_autocmds("LeapLeave")
    return
  else
    if change_op_3f then
      handle_interrupted_change_op_21()
    else
    end
    if vars.errmsg then
      echo(vars.errmsg)
    else
    end
    hl:cleanup(hl_affected_windows)
    exec_user_autocmds("LeapLeave")
    return
  end
  return nil
end
do
  local _204_ = opts.default.equivalence_classes
  if (nil ~= _204_) then
    opts.default.eq_class_of = eq_classes__3emembership_lookup(_204_)
  else
    opts.default.eq_class_of = _204_
  end
end
api.nvim_create_augroup("LeapDefault", {})
hl["init-highlight"](hl)
local function _206_()
  return hl["init-highlight"](hl)
end
api.nvim_create_autocmd("ColorScheme", {callback = _206_, group = "LeapDefault"})
local function set_editor_opts(t)
  state.saved_editor_opts = {}
  local wins = (state.args.target_windows or {state.source_window})
  for opt, val in pairs(t) do
    local _let_207_ = vim.split(opt, ".", {plain = true})
    local scope = _let_207_[1]
    local name = _let_207_[2]
    local _208_ = scope
    if (_208_ == "w") then
      for _, w in ipairs(wins) do
        state.saved_editor_opts[{"w", w, name}] = api.nvim_win_get_option(w, name)
        api.nvim_win_set_option(w, name, val)
      end
    elseif (_208_ == "b") then
      for _, w in ipairs(wins) do
        local b = api.nvim_win_get_buf(w)
        do end (state.saved_editor_opts)[{"b", b, name}] = api.nvim_buf_get_option(b, name)
        api.nvim_buf_set_option(b, name, val)
      end
    elseif true then
      local _ = _208_
      state.saved_editor_opts[name] = api.nvim_get_option(name)
      api.nvim_set_option(name, val)
    else
    end
  end
  return nil
end
local function restore_editor_opts()
  for key, val in pairs(state.saved_editor_opts) do
    local _210_ = key
    if ((_G.type(_210_) == "table") and ((_210_)[1] == "w") and (nil ~= (_210_)[2]) and (nil ~= (_210_)[3])) then
      local w = (_210_)[2]
      local name = (_210_)[3]
      api.nvim_win_set_option(w, name, val)
    elseif ((_G.type(_210_) == "table") and ((_210_)[1] == "b") and (nil ~= (_210_)[2]) and (nil ~= (_210_)[3])) then
      local b = (_210_)[2]
      local name = (_210_)[3]
      api.nvim_buf_set_option(b, name, val)
    elseif (nil ~= _210_) then
      local name = _210_
      api.nvim_set_option(name, val)
    else
    end
  end
  return nil
end
local temporary_editor_opts = {["w.conceallevel"] = 0, ["g.scrolloff"] = 0, ["w.scrolloff"] = 0, ["g.sidescrolloff"] = 0, ["w.sidescrolloff"] = 0, ["b.modeline"] = false}
local function _212_()
  return set_editor_opts(temporary_editor_opts)
end
api.nvim_create_autocmd("User", {pattern = "LeapEnter", callback = _212_, group = "LeapDefault"})
local function _213_()
  return restore_editor_opts()
end
api.nvim_create_autocmd("User", {pattern = "LeapLeave", callback = _213_, group = "LeapDefault"})
return {state = state, leap = leap}
