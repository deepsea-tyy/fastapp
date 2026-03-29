import { defineComponent as xe, ref as C, inject as Ee, onMounted as ye, onBeforeUnmount as Ce, withDirectives as ne, createVNode as f, resolveDirective as Pe, Fragment as B, mergeProps as L, resolveComponent as N, h as oe, isVNode as ze, vShow as Fe, getCurrentInstance as Ie, nextTick as ke } from "vue";
import { ElRadioGroup as ae, ElCheckboxGroup as le, ElInput as Te, ElMention as $e, ElAutocomplete as Me, ElInputNumber as Le, ElSelect as Ve, ElCascader as Ae, ElSwitch as Re, ElSlider as De, ElTimePicker as Be, ElDatePicker as Ne, ElRate as Ue, ElColorPicker as Ge, ElTransfer as He, ElTimeSelect as We, ElSelectV2 as qe, ElTreeSelect as Je, ElLoadingDirective as Ke, ElForm as Qe, ElFormItem as Xe } from "element-plus";
var Ye = typeof global == "object" && global && global.Object === Object && global, Ze = typeof self == "object" && self && self.Object === Object && self, J = Ye || Ze || Function("return this")(), z = J.Symbol, he = Object.prototype, et = he.hasOwnProperty, tt = he.toString, k = z ? z.toStringTag : void 0, rt = Object.prototype.toString, nt = "[object Null]", ot = "[object Undefined]", ie = z ? z.toStringTag : void 0;
function ge(e) {
  return e == null ? e === void 0 ? ot : nt : ie && ie in Object(e) ? function(t) {
    var r = et.call(t, k), o = t[k];
    try {
      t[k] = void 0;
      var a = !0;
    } catch {
    }
    var u = tt.call(t);
    return a && (r ? t[k] = o : delete t[k]), u;
  }(e) : function(t) {
    return rt.call(t);
  }(e);
}
var at = "[object Symbol]";
function K(e) {
  return typeof e == "symbol" || function(t) {
    return t != null && typeof t == "object";
  }(e) && ge(e) == at;
}
var q = Array.isArray, lt = 1 / 0, ue = z ? z.prototype : void 0, se = ue ? ue.toString : void 0;
function _e(e) {
  if (typeof e == "string") return e;
  if (q(e)) return function(r, o) {
    for (var a = -1, u = r == null ? 0 : r.length, s = Array(u); ++a < u; ) s[a] = o(r[a], a, r);
    return s;
  }(e, _e) + "";
  if (K(e)) return se ? se.call(e) : "";
  var t = e + "";
  return t == "0" && 1 / e == -lt ? "-0" : t;
}
function R(e) {
  var t = typeof e;
  return e != null && (t == "object" || t == "function");
}
var it = "[object AsyncFunction]", ut = "[object Function]", st = "[object GeneratorFunction]", ct = "[object Proxy]", ce, U = J["__core-js_shared__"], pe = (ce = /[^.]+$/.exec(U && U.keys && U.keys.IE_PROTO || "")) ? "Symbol(src)_1." + ce : "", pt = Function.prototype.toString, ft = /^\[object .+?Constructor\]$/, dt = Function.prototype, vt = Object.prototype, mt = dt.toString, yt = vt.hasOwnProperty, ht = RegExp("^" + mt.call(yt).replace(/[\\^$.*+?()[\]{}|]/g, "\\$&").replace(/hasOwnProperty|(function).*?(?=\\\()| for .+?(?=\\\])/g, "$1.*?") + "$");
function gt(e) {
  if (!R(e) || (t = e, pe && pe in t)) return !1;
  var t, r = function(o) {
    if (!R(o)) return !1;
    var a = ge(o);
    return a == ut || a == st || a == it || a == ct;
  }(e) ? ht : ft;
  return r.test(function(o) {
    if (o != null) {
      try {
        return pt.call(o);
      } catch {
      }
      try {
        return o + "";
      } catch {
      }
    }
    return "";
  }(e));
}
function Q(e, t) {
  var r = function(o, a) {
    return o == null ? void 0 : o[a];
  }(e, t);
  return gt(r) ? r : void 0;
}
var fe = function() {
  try {
    var e = Q(Object, "defineProperty");
    return e({}, "", {}), e;
  } catch {
  }
}(), _t = 9007199254740991, bt = /^(?:0|[1-9]\d*)$/;
function wt(e, t) {
  var r = typeof e;
  return !!(t = t ?? _t) && (r == "number" || r != "symbol" && bt.test(e)) && e > -1 && e % 1 == 0 && e < t;
}
function be(e, t) {
  return e === t || e != e && t != t;
}
var jt = Object.prototype.hasOwnProperty;
function St(e, t, r) {
  var o = e[t];
  jt.call(e, t) && be(o, r) && (r !== void 0 || t in e) || function(a, u, s) {
    u == "__proto__" && fe ? fe(a, u, { configurable: !0, enumerable: !0, value: s, writable: !0 }) : a[u] = s;
  }(e, t, r);
}
var Ot = /\.|\[(?:[^[\]]*|(["'])(?:(?!\1)[^\\]|\\.)*?\1)\]/, xt = /^\w*$/, T = Q(Object, "create"), Et = Object.prototype.hasOwnProperty, Ct = Object.prototype.hasOwnProperty;
function j(e) {
  var t = -1, r = e == null ? 0 : e.length;
  for (this.clear(); ++t < r; ) {
    var o = e[t];
    this.set(o[0], o[1]);
  }
}
function V(e, t) {
  for (var r = e.length; r--; ) if (be(e[r][0], t)) return r;
  return -1;
}
j.prototype.clear = function() {
  this.__data__ = T ? T(null) : {}, this.size = 0;
}, j.prototype.delete = function(e) {
  var t = this.has(e) && delete this.__data__[e];
  return this.size -= t ? 1 : 0, t;
}, j.prototype.get = function(e) {
  var t = this.__data__;
  if (T) {
    var r = t[e];
    return r === "__lodash_hash_undefined__" ? void 0 : r;
  }
  return Et.call(t, e) ? t[e] : void 0;
}, j.prototype.has = function(e) {
  var t = this.__data__;
  return T ? t[e] !== void 0 : Ct.call(t, e);
}, j.prototype.set = function(e, t) {
  var r = this.__data__;
  return this.size += this.has(e) ? 0 : 1, r[e] = T && t === void 0 ? "__lodash_hash_undefined__" : t, this;
};
var Pt = Array.prototype.splice;
function P(e) {
  var t = -1, r = e == null ? 0 : e.length;
  for (this.clear(); ++t < r; ) {
    var o = e[t];
    this.set(o[0], o[1]);
  }
}
P.prototype.clear = function() {
  this.__data__ = [], this.size = 0;
}, P.prototype.delete = function(e) {
  var t = this.__data__, r = V(t, e);
  return !(r < 0) && (r == t.length - 1 ? t.pop() : Pt.call(t, r, 1), --this.size, !0);
}, P.prototype.get = function(e) {
  var t = this.__data__, r = V(t, e);
  return r < 0 ? void 0 : t[r][1];
}, P.prototype.has = function(e) {
  return V(this.__data__, e) > -1;
}, P.prototype.set = function(e, t) {
  var r = this.__data__, o = V(r, e);
  return o < 0 ? (++this.size, r.push([e, t])) : r[o][1] = t, this;
};
var zt = Q(J, "Map");
function A(e, t) {
  var r, o, a = e.__data__;
  return ((o = typeof (r = t)) == "string" || o == "number" || o == "symbol" || o == "boolean" ? r !== "__proto__" : r === null) ? a[typeof t == "string" ? "string" : "hash"] : a.map;
}
function S(e) {
  var t = -1, r = e == null ? 0 : e.length;
  for (this.clear(); ++t < r; ) {
    var o = e[t];
    this.set(o[0], o[1]);
  }
}
S.prototype.clear = function() {
  this.size = 0, this.__data__ = { hash: new j(), map: new (zt || P)(), string: new j() };
}, S.prototype.delete = function(e) {
  var t = A(this, e).delete(e);
  return this.size -= t ? 1 : 0, t;
}, S.prototype.get = function(e) {
  return A(this, e).get(e);
}, S.prototype.has = function(e) {
  return A(this, e).has(e);
}, S.prototype.set = function(e, t) {
  var r = A(this, e), o = r.size;
  return r.set(e, t), this.size += r.size == o ? 0 : 1, this;
};
var Ft = "Expected a function";
function X(e, t) {
  if (typeof e != "function" || t != null && typeof t != "function") throw new TypeError(Ft);
  var r = function() {
    var o = arguments, a = t ? t.apply(this, o) : o[0], u = r.cache;
    if (u.has(a)) return u.get(a);
    var s = e.apply(this, o);
    return r.cache = u.set(a, s) || u, s;
  };
  return r.cache = new (X.Cache || S)(), r;
}
X.Cache = S;
var de, G, H, It = /[^.[\]]+|\[(?:(-?\d+(?:\.\d+)?)|(["'])((?:(?!\2)[^\\]|\\.)*?)\2)\]|(?=(?:\.|\[\])(?:\.|\[\]|$))/g, kt = /\\(\\)?/g, Tt = (de = function(e) {
  var t = [];
  return e.charCodeAt(0) === 46 && t.push(""), e.replace(It, function(r, o, a, u) {
    t.push(a ? u.replace(kt, "$1") : o || r);
  }), t;
}, G = X(de, function(e) {
  return H.size === 500 && H.clear(), e;
}), H = G.cache, G);
function we(e, t) {
  return q(e) ? e : function(r, o) {
    if (q(r)) return !1;
    var a = typeof r;
    return !(a != "number" && a != "symbol" && a != "boolean" && r != null && !K(r)) || xt.test(r) || !Ot.test(r) || o != null && r in Object(o);
  }(e, t) ? [e] : Tt(function(r) {
    return r == null ? "" : _e(r);
  }(e));
}
var $t = 1 / 0;
function je(e) {
  if (typeof e == "string" || K(e)) return e;
  var t = e + "";
  return t == "0" && 1 / e == -$t ? "-0" : t;
}
function Mt(e, t, r) {
  var o = e == null ? void 0 : function(a, u) {
    for (var s = 0, _ = (u = we(u, a)).length; a != null && s < _; ) a = a[je(u[s++])];
    return s && s == _ ? a : void 0;
  }(e, t);
  return o === void 0 ? r : o;
}
function Lt(e, t, r) {
  return e == null ? e : function(o, a, u) {
    if (!R(o)) return o;
    for (var s = -1, _ = (a = we(a, o)).length, F = _ - 1, h = o; h != null && ++s < _; ) {
      var v = je(a[s]), O = u;
      if (v === "__proto__" || v === "constructor" || v === "prototype") return o;
      if (s != F) {
        var x = h[v];
        (O = void 0) == void 0 && (O = R(x) ? x : wt(a[s + 1]) ? [] : {});
      }
      St(h, v, O), h = h[v];
    }
    return o;
  }(e, t, r);
}
const ve = { Radio: ae, Checkbox: le, CheckboxButton: le, Input: Te, Mention: $e, Autocomplete: Me, InputNumber: Le, Select: Ve, Cascader: Ae, Switch: Re, Slider: De, TimePicker: Be, DatePicker: Ne, Rate: Ue, ColorPicker: Ge, Transfer: He, TimeSelect: We, SelectV2: qe, TreeSelect: Je, RadioButton: ae };
function W(e) {
  return typeof e == "function" || Object.prototype.toString.call(e) === "[object Object]" && !ze(e);
}
const me = xe({ name: "MaForm", props: { modelValue: { type: Object, default: () => ({}) }, options: { type: Object, default: () => ({}) }, items: { type: Array, default: () => [] } }, directives: { Loading: Ke }, setup(e, { slots: t, attrs: r, expose: o }) {
  const a = C(e.modelValue), u = C(e.options), s = C(e.items), _ = Ee("MaFormOptions"), F = C(!1), h = C(), v = C(!1), O = () => {
    v.value = window.innerWidth < 768;
  };
  ye(async () => {
    F.value = !0, window.addEventListener("resize", O);
  }), Ce(() => {
    F.value = !1, window.removeEventListener("resize", O);
  });
  const x = (l, n) => {
    var m, b, p, w, y;
    const c = typeof n.prop == "function" ? n.prop() : n.prop;
    let d = null;
    return (m = l == null ? void 0 : l.children) != null && m.default ? d = (b = l == null ? void 0 : l.children) == null ? void 0 : b.default : (p = n == null ? void 0 : n.renderSlots) != null && p.default ? d = (w = n.renderSlots) == null ? void 0 : w.default : n != null && n.children && (d = D((n == null ? void 0 : n.children) ?? [])), oe(l, { ref: "formItem-{$prop}", modelValue: Mt(a.value, c), "onUpdate:modelValue": (I) => Lt(a.value, c, I), ...n == null ? void 0 : n.renderProps }, { ...(n == null ? void 0 : n.renderSlots) ?? null, default: n != null && n.children && !((y = n.renderSlots) != null && y.default) && typeof l.type == "string" ? () => d : d });
  }, Se = (l) => {
    if (typeof l.render == "string") {
      const n = l.render[0].toUpperCase().concat(l.render.substring(1, l.render.length));
      if (ve[n]) return x(ve[n], l);
    } else {
      if (typeof l.render == "function") {
        const n = l.render;
        return x(n({ item: l, formData: a.value }), l);
      }
      if (!l.render)
        return x((() => f("div", null, null))({ item: l, formData: a.value }), l);
    }
  }, D = (l) => {
    const { layout: n } = u.value;
    return l == null ? void 0 : l.map((c) => {
      let d;
      const { label: m, prop: b, itemProps: p, hide: w, show: y, cols: I, itemSlots: i } = c, $ = typeof w == "function" ? w : () => w === !0, M = typeof y == "function" ? y : () => y !== !1, ee = typeof b == "function" ? b() : b, te = () => ne(f(Xe, L({ ref: `formItemRef-${ee}`, label: typeof m == "function" ? m() : m, prop: ee }, p), { default: () => {
        var E, g, re;
        return f(B, null, [((E = i == null ? void 0 : i.default) == null ? void 0 : E.call(i)) ?? Se(c), f("div", null, [((p == null ? void 0 : p.help) || (i == null ? void 0 : i.help)) && f("div", { style: "font-size:12px; line-height: 22px; color: #909399" }, [((g = i == null ? void 0 : i.help) == null ? void 0 : g.call(i, c)) || (p == null ? void 0 : p.help)]), ((p == null ? void 0 : p.extra) || (i == null ? void 0 : i.extra)) && f("div", { style: "font-size:12px; line-height: 22px; color: #909399" }, [((re = i == null ? void 0 : i.extra) == null ? void 0 : re.call(i, c)) || (p == null ? void 0 : p.extra)])])]);
      }, label: i != null && i.label ? (E) => {
        var g;
        return ((g = i == null ? void 0 : i.label) == null ? void 0 : g.call(i, E)) ?? null;
      } : void 0, error: i != null && i.error ? (E) => {
        var g;
        return ((g = i == null ? void 0 : i.error) == null ? void 0 : g.call(i, E)) ?? null;
      } : void 0 }), [[Fe, $(c, a.value) !== !0]]);
      return f(B, null, [M(c, a.value) && (n === void 0 || n === "flex" ? f(N("el-col"), I, W(d = te()) ? d : { default: () => [d] }) : te())]);
    });
  }, Oe = () => {
    var $;
    let l, n;
    const { layout: c, flex: d, grid: m, loading: b, loadingConfig: p, containerClass: w, footerSlot: y, ...I } = u.value, { style: i } = m ?? {};
    return f(B, null, [f(Qe, L({ model: a, ref: h }, I, r), { default: () => {
      var M;
      return [((M = t.default) == null ? void 0 : M.call(t)) ?? (c === void 0 || c === "flex" ? f(N("el-row"), L({ gutter: v.value ? 0 : 15 }, d), W(l = D(s.value ?? [])) ? l : { default: () => [l] }) : f(N("el-space"), L({ style: i ?? "width: 100%" }, m), W(n = D(s.value ?? [])) ? n : { default: () => [n] }))];
    } }), (($ = t.footer) == null ? void 0 : $.call(t)) ?? (y ? oe(y) : null)]);
  }, Y = () => {
    const { loading: l, loadingConfig: n, containerClass: c } = u.value;
    return ne(f("div", { className: ["ma-form", c], "element-loading-svg": (n == null ? void 0 : n.svg) ?? '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 1024 1024"><path fill="currentColor" d="M512 64a32 32 0 0 1 32 32v192a32 32 0 0 1-64 0V96a32 32 0 0 1 32-32m0 640a32 32 0 0 1 32 32v192a32 32 0 1 1-64 0V736a32 32 0 0 1 32-32m448-192a32 32 0 0 1-32 32H736a32 32 0 1 1 0-64h192a32 32 0 0 1 32 32m-640 0a32 32 0 0 1-32 32H96a32 32 0 0 1 0-64h192a32 32 0 0 1 32 32M195.2 195.2a32 32 0 0 1 45.248 0L376.32 331.008a32 32 0 0 1-45.248 45.248L195.2 240.448a32 32 0 0 1 0-45.248m452.544 452.544a32 32 0 0 1 45.248 0L828.8 783.552a32 32 0 0 1-45.248 45.248L647.744 692.992a32 32 0 0 1 0-45.248M828.8 195.264a32 32 0 0 1 0 45.184L692.992 376.32a32 32 0 0 1-45.248-45.248l135.808-135.808a32 32 0 0 1 45.248 0m-452.544 452.48a32 32 0 0 1 0 45.248L240.448 828.8a32 32 0 0 1-45.248-45.248l135.808-135.808a32 32 0 0 1 45.248 0"/></svg>', "element-loading-svg-view-box": (n == null ? void 0 : n.viewBox) ?? "-9, -9, 50, 50", "element-loading-text": (n == null ? void 0 : n.text) ?? null, "element-loading-spinner": (n == null ? void 0 : n.spinner) ?? null, "element-loading-background": (n == null ? void 0 : n.spinner) ?? null, "element-loading-custom-class": (n == null ? void 0 : n.customClass) ?? null }, [Oe()]), [[Pe("loading"), l]]);
  }, Z = (l) => s.value = l;
  return o({ setLoadingState: (l) => u.value.loading = l, setOptions: (l) => u.value = Object.assign(u.value, l), getOptions: () => u.value, setItems: Z, getItems: () => s.value, appendItem: (l) => s.value.push(l), removeItem: (l) => Z(s.value.filter((n) => (typeof n.prop == "function" ? n.prop() : n.prop) !== l)), getItemByProp: (l) => {
    var n;
    return ((n = s.value.filter((c) => (typeof c.prop == "function" ? c.prop() : c.prop) === l)) == null ? void 0 : n[0]) ?? null;
  }, isMobileState: () => v.value, getElFormRef: () => h.value }), () => _.ssr ? F.value && Y() : Y();
} });
function Rt(e) {
  return new Promise((t, r) => {
    const o = Ie();
    ye(async () => {
      await ke(() => {
        if (o && o.refs[e]) {
          const a = o.refs[e];
          t({ ...a });
        } else r("[@ma/form]: not found ref for ma-form component");
      });
    });
  });
}
const Dt = { install(e, t) {
  e.component(me.name, me), e.provide("MaFormOptions", t ?? { ssr: !1 });
} };
export {
  Dt as MaForm,
  Dt as default,
  Rt as useForm
};
