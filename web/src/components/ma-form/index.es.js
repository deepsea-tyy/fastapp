import { defineComponent as Oe, ref as C, inject as Ee, onMounted as me, onBeforeUnmount as Ce, withDirectives as re, createVNode as m, resolveDirective as Pe, Fragment as ne, mergeProps as V, resolveComponent as N, h as oe, isVNode as xe, vShow as ze, getCurrentInstance as Fe, nextTick as Ie } from "vue";
import { ElRadioGroup as ae, ElCheckboxGroup as le, ElInput as ke, ElMention as Te, ElAutocomplete as Me, ElInputNumber as $e, ElSelect as Le, ElCascader as Ve, ElSwitch as Ae, ElSlider as Re, ElTimePicker as Be, ElDatePicker as De, ElRate as Ne, ElColorPicker as Ue, ElTransfer as Ge, ElTimeSelect as He, ElSelectV2 as We, ElTreeSelect as qe, ElLoadingDirective as Je, ElForm as Ke, ElFormItem as Qe } from "element-plus";
var Xe = typeof global == "object" && global && global.Object === Object && global, Ye = typeof self == "object" && self && self.Object === Object && self, J = Xe || Ye || Function("return this")(), x = J.Symbol, ye = Object.prototype, Ze = ye.hasOwnProperty, et = ye.toString, k = x ? x.toStringTag : void 0, tt = Object.prototype.toString, rt = "[object Null]", nt = "[object Undefined]", ie = x ? x.toStringTag : void 0;
function ge(e) {
  return e == null ? e === void 0 ? nt : rt : ie && ie in Object(e) ? function(t) {
    var r = Ze.call(t, k), n = t[k];
    try {
      t[k] = void 0;
      var a = !0;
    } catch {
    }
    var i = et.call(t);
    return a && (r ? t[k] = n : delete t[k]), i;
  }(e) : function(t) {
    return tt.call(t);
  }(e);
}
var ot = "[object Symbol]";
function K(e) {
  return typeof e == "symbol" || function(t) {
    return t != null && typeof t == "object";
  }(e) && ge(e) == ot;
}
var q = Array.isArray, at = 1 / 0, ue = x ? x.prototype : void 0, se = ue ? ue.toString : void 0;
function _e(e) {
  if (typeof e == "string") return e;
  if (q(e)) return function(r, n) {
    for (var a = -1, i = r == null ? 0 : r.length, u = Array(i); ++a < i; ) u[a] = n(r[a], a, r);
    return u;
  }(e, _e) + "";
  if (K(e)) return se ? se.call(e) : "";
  var t = e + "";
  return t == "0" && 1 / e == -at ? "-0" : t;
}
function B(e) {
  var t = typeof e;
  return e != null && (t == "object" || t == "function");
}
var lt = "[object AsyncFunction]", it = "[object Function]", ut = "[object GeneratorFunction]", st = "[object Proxy]", ce, U = J["__core-js_shared__"], fe = (ce = /[^.]+$/.exec(U && U.keys && U.keys.IE_PROTO || "")) ? "Symbol(src)_1." + ce : "", ct = Function.prototype.toString, ft = /^\[object .+?Constructor\]$/, pt = Function.prototype, dt = Object.prototype, vt = pt.toString, ht = dt.hasOwnProperty, mt = RegExp("^" + vt.call(ht).replace(/[\\^$.*+?()[\]{}|]/g, "\\$&").replace(/hasOwnProperty|(function).*?(?=\\\()| for .+?(?=\\\])/g, "$1.*?") + "$");
function yt(e) {
  if (!B(e) || (t = e, fe && fe in t)) return !1;
  var t, r = function(n) {
    if (!B(n)) return !1;
    var a = ge(n);
    return a == it || a == ut || a == lt || a == st;
  }(e) ? mt : ft;
  return r.test(function(n) {
    if (n != null) {
      try {
        return ct.call(n);
      } catch {
      }
      try {
        return n + "";
      } catch {
      }
    }
    return "";
  }(e));
}
function Q(e, t) {
  var r = function(n, a) {
    return n == null ? void 0 : n[a];
  }(e, t);
  return yt(r) ? r : void 0;
}
var pe = function() {
  try {
    var e = Q(Object, "defineProperty");
    return e({}, "", {}), e;
  } catch {
  }
}(), gt = 9007199254740991, _t = /^(?:0|[1-9]\d*)$/;
function bt(e, t) {
  var r = typeof e;
  return !!(t = t ?? gt) && (r == "number" || r != "symbol" && _t.test(e)) && e > -1 && e % 1 == 0 && e < t;
}
function be(e, t) {
  return e === t || e != e && t != t;
}
var wt = Object.prototype.hasOwnProperty;
function jt(e, t, r) {
  var n = e[t];
  wt.call(e, t) && be(n, r) && (r !== void 0 || t in e) || function(a, i, u) {
    i == "__proto__" && pe ? pe(a, i, { configurable: !0, enumerable: !0, value: u, writable: !0 }) : a[i] = u;
  }(e, t, r);
}
var St = /\.|\[(?:[^[\]]*|(["'])(?:(?!\1)[^\\]|\\.)*?\1)\]/, Ot = /^\w*$/, T = Q(Object, "create"), Et = Object.prototype.hasOwnProperty, Ct = Object.prototype.hasOwnProperty;
function w(e) {
  var t = -1, r = e == null ? 0 : e.length;
  for (this.clear(); ++t < r; ) {
    var n = e[t];
    this.set(n[0], n[1]);
  }
}
function A(e, t) {
  for (var r = e.length; r--; ) if (be(e[r][0], t)) return r;
  return -1;
}
w.prototype.clear = function() {
  this.__data__ = T ? T(null) : {}, this.size = 0;
}, w.prototype.delete = function(e) {
  var t = this.has(e) && delete this.__data__[e];
  return this.size -= t ? 1 : 0, t;
}, w.prototype.get = function(e) {
  var t = this.__data__;
  if (T) {
    var r = t[e];
    return r === "__lodash_hash_undefined__" ? void 0 : r;
  }
  return Et.call(t, e) ? t[e] : void 0;
}, w.prototype.has = function(e) {
  var t = this.__data__;
  return T ? t[e] !== void 0 : Ct.call(t, e);
}, w.prototype.set = function(e, t) {
  var r = this.__data__;
  return this.size += this.has(e) ? 0 : 1, r[e] = T && t === void 0 ? "__lodash_hash_undefined__" : t, this;
};
var Pt = Array.prototype.splice;
function P(e) {
  var t = -1, r = e == null ? 0 : e.length;
  for (this.clear(); ++t < r; ) {
    var n = e[t];
    this.set(n[0], n[1]);
  }
}
P.prototype.clear = function() {
  this.__data__ = [], this.size = 0;
}, P.prototype.delete = function(e) {
  var t = this.__data__, r = A(t, e);
  return !(r < 0) && (r == t.length - 1 ? t.pop() : Pt.call(t, r, 1), --this.size, !0);
}, P.prototype.get = function(e) {
  var t = this.__data__, r = A(t, e);
  return r < 0 ? void 0 : t[r][1];
}, P.prototype.has = function(e) {
  return A(this.__data__, e) > -1;
}, P.prototype.set = function(e, t) {
  var r = this.__data__, n = A(r, e);
  return n < 0 ? (++this.size, r.push([e, t])) : r[n][1] = t, this;
};
var xt = Q(J, "Map");
function R(e, t) {
  var r, n, a = e.__data__;
  return ((n = typeof (r = t)) == "string" || n == "number" || n == "symbol" || n == "boolean" ? r !== "__proto__" : r === null) ? a[typeof t == "string" ? "string" : "hash"] : a.map;
}
function j(e) {
  var t = -1, r = e == null ? 0 : e.length;
  for (this.clear(); ++t < r; ) {
    var n = e[t];
    this.set(n[0], n[1]);
  }
}
j.prototype.clear = function() {
  this.size = 0, this.__data__ = { hash: new w(), map: new (xt || P)(), string: new w() };
}, j.prototype.delete = function(e) {
  var t = R(this, e).delete(e);
  return this.size -= t ? 1 : 0, t;
}, j.prototype.get = function(e) {
  return R(this, e).get(e);
}, j.prototype.has = function(e) {
  return R(this, e).has(e);
}, j.prototype.set = function(e, t) {
  var r = R(this, e), n = r.size;
  return r.set(e, t), this.size += r.size == n ? 0 : 1, this;
};
var zt = "Expected a function";
function X(e, t) {
  if (typeof e != "function" || t != null && typeof t != "function") throw new TypeError(zt);
  var r = function() {
    var n = arguments, a = t ? t.apply(this, n) : n[0], i = r.cache;
    if (i.has(a)) return i.get(a);
    var u = e.apply(this, n);
    return r.cache = i.set(a, u) || i, u;
  };
  return r.cache = new (X.Cache || j)(), r;
}
X.Cache = j;
var de, G, H, Ft = /[^.[\]]+|\[(?:(-?\d+(?:\.\d+)?)|(["'])((?:(?!\2)[^\\]|\\.)*?)\2)\]|(?=(?:\.|\[\])(?:\.|\[\]|$))/g, It = /\\(\\)?/g, kt = (de = function(e) {
  var t = [];
  return e.charCodeAt(0) === 46 && t.push(""), e.replace(Ft, function(r, n, a, i) {
    t.push(a ? i.replace(It, "$1") : n || r);
  }), t;
}, G = X(de, function(e) {
  return H.size === 500 && H.clear(), e;
}), H = G.cache, G);
function we(e, t) {
  return q(e) ? e : function(r, n) {
    if (q(r)) return !1;
    var a = typeof r;
    return !(a != "number" && a != "symbol" && a != "boolean" && r != null && !K(r)) || Ot.test(r) || !St.test(r) || n != null && r in Object(n);
  }(e, t) ? [e] : kt(function(r) {
    return r == null ? "" : _e(r);
  }(e));
}
var Tt = 1 / 0;
function je(e) {
  if (typeof e == "string" || K(e)) return e;
  var t = e + "";
  return t == "0" && 1 / e == -Tt ? "-0" : t;
}
function Mt(e, t, r) {
  var n = e == null ? void 0 : function(a, i) {
    for (var u = 0, g = (i = we(i, a)).length; a != null && u < g; ) a = a[je(i[u++])];
    return u && u == g ? a : void 0;
  }(e, t);
  return n === void 0 ? r : n;
}
function $t(e, t, r) {
  return e == null ? e : function(n, a, i) {
    if (!B(n)) return n;
    for (var u = -1, g = (a = we(a, n)).length, z = g - 1, y = n; y != null && ++u < g; ) {
      var d = je(a[u]), S = i;
      if (d === "__proto__" || d === "constructor" || d === "prototype") return n;
      if (u != z) {
        var O = y[d];
        (S = void 0) == void 0 && (S = B(O) ? O : bt(a[u + 1]) ? [] : {});
      }
      jt(y, d, S), y = y[d];
    }
    return n;
  }(e, t, r);
}
const ve = { Radio: ae, Checkbox: le, CheckboxButton: le, Input: ke, Mention: Te, Autocomplete: Me, InputNumber: $e, Select: Le, Cascader: Ve, Switch: Ae, Slider: Re, TimePicker: Be, DatePicker: De, Rate: Ne, ColorPicker: Ue, Transfer: Ge, TimeSelect: He, SelectV2: We, TreeSelect: qe, RadioButton: ae };
function W(e) {
  return typeof e == "function" || Object.prototype.toString.call(e) === "[object Object]" && !xe(e);
}
const he = Oe({ name: "MaForm", props: { modelValue: { type: Object, default: () => ({}) }, options: { type: Object, default: () => ({}) }, items: { type: Array, default: () => [] } }, directives: { Loading: Je }, setup(e, { slots: t, attrs: r, expose: n }) {
  const a = C(e.modelValue), i = C(e.options), u = C(e.items), g = Ee("MaFormOptions"), z = C(!1), y = C(), d = C(!1), S = () => {
    d.value = window.innerWidth < 768;
  };
  me(async () => {
    z.value = !0, window.addEventListener("resize", S);
  }), Ce(() => {
    z.value = !1, window.removeEventListener("resize", S);
  });
  const O = (l, o) => {
    var v, _, F, b, h;
    const f = typeof o.prop == "function" ? o.prop() : o.prop;
    let p = null;
    return (v = l == null ? void 0 : l.children) != null && v.default ? p = (_ = l == null ? void 0 : l.children) == null ? void 0 : _.default : (F = o == null ? void 0 : o.renderSlots) != null && F.default ? p = (b = o.renderSlots) == null ? void 0 : b.default : o != null && o.children && (p = D((o == null ? void 0 : o.children) ?? [])), oe(l, { ref: "formItem-{$prop}", modelValue: Mt(a.value, f), "onUpdate:modelValue": (I) => $t(a.value, f, I), ...o == null ? void 0 : o.renderProps }, { ...(o == null ? void 0 : o.renderSlots) ?? null, default: o != null && o.children && !((h = o.renderSlots) != null && h.default) && typeof l.type == "string" ? () => p : p });
  }, D = (l) => {
    const { layout: o } = i.value;
    return l == null ? void 0 : l.map((f) => {
      let p;
      const { label: v, prop: _, itemProps: F, hide: b, show: h, cols: I, itemSlots: s } = f, M = typeof b == "function" ? b : () => b === !0, $ = typeof h == "function" ? h : () => h !== !1, ee = typeof _ == "function" ? _() : _, te = () => re(m(Qe, V({ ref: `formItemRef-${ee}`, label: typeof v == "function" ? v() : v, prop: ee }, F), { default: () => {
        var E;
        return ((E = s == null ? void 0 : s.default) == null ? void 0 : E.call(s)) ?? ((c) => {
          if (typeof c.render == "string") {
            const L = c.render[0].toUpperCase().concat(c.render.substring(1, c.render.length));
            if (ve[L]) return O(ve[L], c);
          } else {
            if (typeof c.render == "function") {
              const L = c.render;
              return O(L({ item: c, formData: a.value }), c);
            }
            if (!c.render) return O((a.value, m("div", null, null)), c);
          }
        })(f);
      }, label: s != null && s.label ? (E) => {
        var c;
        return ((c = s == null ? void 0 : s.label) == null ? void 0 : c.call(s, E)) ?? null;
      } : void 0, error: s != null && s.error ? (E) => {
        var c;
        return ((c = s == null ? void 0 : s.error) == null ? void 0 : c.call(s, E)) ?? null;
      } : void 0 }), [[ze, M(f, a.value) !== !0]]);
      return m(ne, null, [$(f, a.value) && (o === void 0 || o === "flex" ? m(N("el-col"), I, W(p = te()) ? p : { default: () => [p] }) : te())]);
    });
  }, Se = () => {
    var M;
    let l, o;
    const { layout: f, flex: p, grid: v, loading: _, loadingConfig: F, containerClass: b, footerSlot: h, ...I } = i.value, { style: s } = v ?? {};
    return m(ne, null, [m(Ke, V({ model: a, ref: y }, I, r), { default: () => {
      var $;
      return [(($ = t.default) == null ? void 0 : $.call(t)) ?? (f === void 0 || f === "flex" ? m(N("el-row"), V({ gutter: d.value ? 0 : 15 }, p), W(l = D(u.value ?? [])) ? l : { default: () => [l] }) : m(N("el-space"), V({ style: s ?? "width: 100%" }, v), W(o = D(u.value ?? [])) ? o : { default: () => [o] }))];
    } }), ((M = t.footer) == null ? void 0 : M.call(t)) ?? (h ? oe(h) : null)]);
  }, Y = () => {
    const { loading: l, loadingConfig: o, containerClass: f } = i.value;
    return re(m("div", { className: ["base.form", f], "element-loading-svg": (o == null ? void 0 : o.svg) ?? '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 1024 1024"><path fill="currentColor" d="M512 64a32 32 0 0 1 32 32v192a32 32 0 0 1-64 0V96a32 32 0 0 1 32-32m0 640a32 32 0 0 1 32 32v192a32 32 0 1 1-64 0V736a32 32 0 0 1 32-32m448-192a32 32 0 0 1-32 32H736a32 32 0 1 1 0-64h192a32 32 0 0 1 32 32m-640 0a32 32 0 0 1-32 32H96a32 32 0 0 1 0-64h192a32 32 0 0 1 32 32M195.2 195.2a32 32 0 0 1 45.248 0L376.32 331.008a32 32 0 0 1-45.248 45.248L195.2 240.448a32 32 0 0 1 0-45.248m452.544 452.544a32 32 0 0 1 45.248 0L828.8 783.552a32 32 0 0 1-45.248 45.248L647.744 692.992a32 32 0 0 1 0-45.248M828.8 195.264a32 32 0 0 1 0 45.184L692.992 376.32a32 32 0 0 1-45.248-45.248l135.808-135.808a32 32 0 0 1 45.248 0m-452.544 452.48a32 32 0 0 1 0 45.248L240.448 828.8a32 32 0 0 1-45.248-45.248l135.808-135.808a32 32 0 0 1 45.248 0"/></svg>', "element-loading-svg-view-box": (o == null ? void 0 : o.viewBox) ?? "-9, -9, 50, 50", "element-loading-text": (o == null ? void 0 : o.text) ?? null, "element-loading-spinner": (o == null ? void 0 : o.spinner) ?? null, "element-loading-background": (o == null ? void 0 : o.spinner) ?? null, "element-loading-custom-class": (o == null ? void 0 : o.customClass) ?? null }, [Se()]), [[Pe("loading"), l]]);
  }, Z = (l) => u.value = l;
  return n({ setLoadingState: (l) => i.value.loading = l, setOptions: (l) => i.value = Object.assign(i.value, l), getOptions: () => i.value, setItems: Z, getItems: () => u.value, appendItem: (l) => u.value.push(l), removeItem: (l) => Z(u.value.filter((o) => (typeof o.prop == "function" ? o.prop() : o.prop) !== l)), getItemByProp: (l) => {
    var o;
    return ((o = u.value.filter((f) => (typeof f.prop == "function" ? f.prop() : f.prop) === l)) == null ? void 0 : o[0]) ?? null;
  }, isMobileState: () => d.value, getElFormRef: () => y.value }), () => g.ssr ? z.value && Y() : Y();
} });
function At(e) {
  return new Promise((t, r) => {
    const n = Fe();
    me(async () => {
      await Ie(() => {
        if (n && n.refs[e]) {
          const a = n.refs[e];
          t({ ...a });
        } else r("[@base.form]: not found ref for ma-form component");
      });
    });
  });
}
const Rt = { install(e, t) {
  e.component(he.name, he), e.provide("MaFormOptions", t ?? { ssr: !1 });
} };
export {
  Rt as MaForm,
  Rt as default,
  At as useForm
};
