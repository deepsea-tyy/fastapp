import { onMounted as jt, nextTick as He, getCurrentScope as Sn, onScopeDispose as Tn, getCurrentInstance as cn, unref as un, isRef as En, inject as qt, createElementBlock as xe, openBlock as te, createElementVNode as de, defineComponent as at, computed as lt, ref as ee, shallowRef as xn, watch as Cn, onBeforeUnmount as _n, createVNode as g, Fragment as Me, withDirectives as Dn, resolveComponent as L, vShow as On, h as Ft, mergeProps as $t, isVNode as Pn, createBlock as nt, withCtx as Se, normalizeClass as Mn, renderList as Nn, createCommentVNode as Rn, toDisplayString as In } from "vue";
import { ElTag as kn } from "element-plus";
const me = (e) => !!(e && e.constructor && e.call && e.apply), Wt = (e, t, n = !1) => e ? e.slice().sort(n === !0 ? (o, a) => t(a) - t(o) : (o, a) => t(o) - t(a)) : [];
function xt(e) {
  return typeof e == "function" ? e() : un(e);
}
const An = typeof window < "u" && typeof document < "u";
function Bn(e, t = !0, n) {
  cn() ? jt(e, n) : t ? e() : He(e);
}
const Fn = An ? window.document : void 0;
/**!
 * Sortable 1.15.2
 * @author	RubaXa   <trash@rubaxa.org>
 * @author	owenm    <owen23355@gmail.com>
 * @license MIT
 */
function Vt(e, t) {
  var n = Object.keys(e);
  if (Object.getOwnPropertySymbols) {
    var o = Object.getOwnPropertySymbols(e);
    t && (o = o.filter(function(a) {
      return Object.getOwnPropertyDescriptor(e, a).enumerable;
    })), n.push.apply(n, o);
  }
  return n;
}
function Te(e) {
  for (var t = 1; t < arguments.length; t++) {
    var n = arguments[t] != null ? arguments[t] : {};
    t % 2 ? Vt(Object(n), !0).forEach(function(o) {
      Hn(e, o, n[o]);
    }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(e, Object.getOwnPropertyDescriptors(n)) : Vt(Object(n)).forEach(function(o) {
      Object.defineProperty(e, o, Object.getOwnPropertyDescriptor(n, o));
    });
  }
  return e;
}
function Ht(e) {
  return Ht = typeof Symbol == "function" && typeof Symbol.iterator == "symbol" ? function(t) {
    return typeof t;
  } : function(t) {
    return t && typeof Symbol == "function" && t.constructor === Symbol && t !== Symbol.prototype ? "symbol" : typeof t;
  }, Ht(e);
}
function Hn(e, t, n) {
  return t in e ? Object.defineProperty(e, t, { value: n, enumerable: !0, configurable: !0, writable: !0 }) : e[t] = n, e;
}
function _e() {
  return _e = Object.assign || function(e) {
    for (var t = 1; t < arguments.length; t++) {
      var n = arguments[t];
      for (var o in n) Object.prototype.hasOwnProperty.call(n, o) && (e[o] = n[o]);
    }
    return e;
  }, _e.apply(this, arguments);
}
function zn(e, t) {
  if (e == null) return {};
  var n, o, a = (function(i, c) {
    if (i == null) return {};
    var l, p, s = {}, f = Object.keys(i);
    for (p = 0; p < f.length; p++) l = f[p], c.indexOf(l) >= 0 || (s[l] = i[l]);
    return s;
  })(e, t);
  if (Object.getOwnPropertySymbols) {
    var r = Object.getOwnPropertySymbols(e);
    for (o = 0; o < r.length; o++) n = r[o], t.indexOf(n) >= 0 || Object.prototype.propertyIsEnumerable.call(e, n) && (a[n] = e[n]);
  }
  return a;
}
function De(e) {
  if (typeof window < "u" && window.navigator) return !!navigator.userAgent.match(e);
}
var Oe = De(/(?:Trident.*rv[ :]?11\.|msie|iemobile|Windows Phone)/i), rt = De(/Edge/i), Gt = De(/firefox/i), Qe = De(/safari/i) && !De(/chrome/i) && !De(/android/i), dn = De(/iP(ad|od|hone)/i), hn = De(/chrome/i) && De(/android/i), pn = { capture: !1, passive: !1 };
function M(e, t, n) {
  e.addEventListener(t, n, !Oe && pn);
}
function D(e, t, n) {
  e.removeEventListener(t, n, !Oe && pn);
}
function bt(e, t) {
  if (t) {
    if (t[0] === ">" && (t = t.substring(1)), e) try {
      if (e.matches) return e.matches(t);
      if (e.msMatchesSelector) return e.msMatchesSelector(t);
      if (e.webkitMatchesSelector) return e.webkitMatchesSelector(t);
    } catch {
      return !1;
    }
    return !1;
  }
}
function Ln(e) {
  return e.host && e !== document && e.host.nodeType ? e.host : e.parentNode;
}
function be(e, t, n, o) {
  if (e) {
    n = n || document;
    do {
      if (t != null && (t[0] === ">" ? e.parentNode === n && bt(e, t) : bt(e, t)) || o && e === n) return e;
      if (e === n) break;
    } while (e = Ln(e));
  }
  return null;
}
var et, Kt = /\s+/g;
function se(e, t, n) {
  if (e && t) if (e.classList) e.classList[n ? "add" : "remove"](t);
  else {
    var o = (" " + e.className + " ").replace(Kt, " ").replace(" " + t + " ", " ");
    e.className = (o + (n ? " " + t : "")).replace(Kt, " ");
  }
}
function w(e, t, n) {
  var o = e && e.style;
  if (o) {
    if (n === void 0) return document.defaultView && document.defaultView.getComputedStyle ? n = document.defaultView.getComputedStyle(e, "") : e.currentStyle && (n = e.currentStyle), t === void 0 ? n : n[t];
    t in o || t.indexOf("webkit") !== -1 || (t = "-webkit-" + t), o[t] = n + (typeof n == "string" ? "" : "px");
  }
}
function $e(e, t) {
  var n = "";
  if (typeof e == "string") n = e;
  else do {
    var o = w(e, "transform");
    o && o !== "none" && (n = o + " " + n);
  } while (!t && (e = e.parentNode));
  var a = window.DOMMatrix || window.WebKitCSSMatrix || window.CSSMatrix || window.MSCSSMatrix;
  return a && new a(n);
}
function Ut(e, t, n) {
  if (e) {
    var o = e.getElementsByTagName(t), a = 0, r = o.length;
    if (n) for (; a < r; a++) n(o[a], a);
    return o;
  }
  return [];
}
function Ee() {
  var e = document.scrollingElement;
  return e || document.documentElement;
}
function Y(e, t, n, o, a) {
  if (e.getBoundingClientRect || e === window) {
    var r, i, c, l, p, s, f;
    if (e !== window && e.parentNode && e !== Ee() ? (i = (r = e.getBoundingClientRect()).top, c = r.left, l = r.bottom, p = r.right, s = r.height, f = r.width) : (i = 0, c = 0, l = window.innerHeight, p = window.innerWidth, s = window.innerHeight, f = window.innerWidth), (t || n) && e !== window && (a = a || e.parentNode, !Oe)) do
      if (a && a.getBoundingClientRect && (w(a, "transform") !== "none" || n && w(a, "position") !== "static")) {
        var E = a.getBoundingClientRect();
        i -= E.top + parseInt(w(a, "border-top-width")), c -= E.left + parseInt(w(a, "border-left-width")), l = i + r.height, p = c + r.width;
        break;
      }
    while (a = a.parentNode);
    if (o && e !== window) {
      var m = $e(a || e), I = m && m.a, C = m && m.d;
      m && (l = (i /= C) + (s /= C), p = (c /= I) + (f /= I));
    }
    return { top: i, left: c, bottom: l, right: p, width: f, height: s };
  }
}
function Jt(e, t, n) {
  for (var o = Ie(e, !0), a = Y(e)[t]; o; ) {
    if (!(a >= Y(o)[n])) return o;
    if (o === Ee()) break;
    o = Ie(o, !1);
  }
  return !1;
}
function We(e, t, n, o) {
  for (var a = 0, r = 0, i = e.children; r < i.length; ) {
    if (i[r].style.display !== "none" && i[r] !== b.ghost && (o || i[r] !== b.dragged) && be(i[r], n.draggable, e, !1)) {
      if (a === t) return i[r];
      a++;
    }
    r++;
  }
  return null;
}
function zt(e, t) {
  for (var n = e.lastElementChild; n && (n === b.ghost || w(n, "display") === "none" || t && !bt(n, t)); ) n = n.previousElementSibling;
  return n || null;
}
function fe(e, t) {
  var n = 0;
  if (!e || !e.parentNode) return -1;
  for (; e = e.previousElementSibling; ) e.nodeName.toUpperCase() === "TEMPLATE" || e === b.clone || t && !bt(e, t) || n++;
  return n;
}
function Zt(e) {
  var t = 0, n = 0, o = Ee();
  if (e) do {
    var a = $e(e), r = a.a, i = a.d;
    t += e.scrollLeft * r, n += e.scrollTop * i;
  } while (e !== o && (e = e.parentNode));
  return [t, n];
}
function Ie(e, t) {
  if (!e || !e.getBoundingClientRect) return Ee();
  var n = e, o = !1;
  do
    if (n.clientWidth < n.scrollWidth || n.clientHeight < n.scrollHeight) {
      var a = w(n);
      if (n.clientWidth < n.scrollWidth && (a.overflowX == "auto" || a.overflowX == "scroll") || n.clientHeight < n.scrollHeight && (a.overflowY == "auto" || a.overflowY == "scroll")) {
        if (!n.getBoundingClientRect || n === document.body) return Ee();
        if (o || t) return n;
        o = !0;
      }
    }
  while (n = n.parentNode);
  return Ee();
}
function Ct(e, t) {
  return Math.round(e.top) === Math.round(t.top) && Math.round(e.left) === Math.round(t.left) && Math.round(e.height) === Math.round(t.height) && Math.round(e.width) === Math.round(t.width);
}
function fn(e, t) {
  return function() {
    if (!et) {
      var n = arguments;
      n.length === 1 ? e.call(this, n[0]) : e.apply(this, n), et = setTimeout(function() {
        et = void 0;
      }, t);
    }
  };
}
function mn(e, t, n) {
  e.scrollLeft += t, e.scrollTop += n;
}
function Qt(e) {
  var t = window.Polymer, n = window.jQuery || window.Zepto;
  return t && t.dom ? t.dom(e).cloneNode(!0) : n ? n(e).clone(!0)[0] : e.cloneNode(!0);
}
function en(e, t, n) {
  var o = {};
  return Array.from(e.children).forEach(function(a) {
    var r, i, c, l;
    if (be(a, t.draggable, e, !1) && !a.animated && a !== n) {
      var p = Y(a);
      o.left = Math.min((r = o.left) !== null && r !== void 0 ? r : 1 / 0, p.left), o.top = Math.min((i = o.top) !== null && i !== void 0 ? i : 1 / 0, p.top), o.right = Math.max((c = o.right) !== null && c !== void 0 ? c : -1 / 0, p.right), o.bottom = Math.max((l = o.bottom) !== null && l !== void 0 ? l : -1 / 0, p.bottom);
    }
  }), o.width = o.right - o.left, o.height = o.bottom - o.top, o.x = o.left, o.y = o.top, o;
}
var ue = "Sortable" + (/* @__PURE__ */ new Date()).getTime();
function Xn() {
  var e, t = [];
  return { captureAnimationState: function() {
    t = [], this.options.animation && [].slice.call(this.el.children).forEach(function(n) {
      if (w(n, "display") !== "none" && n !== b.ghost) {
        t.push({ target: n, rect: Y(n) });
        var o = Te({}, t[t.length - 1].rect);
        if (n.thisAnimationDuration) {
          var a = $e(n, !0);
          a && (o.top -= a.f, o.left -= a.e);
        }
        n.fromRect = o;
      }
    });
  }, addAnimationState: function(n) {
    t.push(n);
  }, removeAnimationState: function(n) {
    t.splice((function(o, a) {
      for (var r in o) if (o.hasOwnProperty(r)) {
        for (var i in a) if (a.hasOwnProperty(i) && a[i] === o[r][i]) return Number(r);
      }
      return -1;
    })(t, { target: n }), 1);
  }, animateAll: function(n) {
    var o = this;
    if (!this.options.animation) return clearTimeout(e), void (typeof n == "function" && n());
    var a = !1, r = 0;
    t.forEach(function(i) {
      var c = 0, l = i.target, p = l.fromRect, s = Y(l), f = l.prevFromRect, E = l.prevToRect, m = i.rect, I = $e(l, !0);
      I && (s.top -= I.f, s.left -= I.e), l.toRect = s, l.thisAnimationDuration && Ct(f, s) && !Ct(p, s) && (m.top - s.top) / (m.left - s.left) === (p.top - s.top) / (p.left - s.left) && (c = (function(C, x, $, re) {
        return Math.sqrt(Math.pow(x.top - C.top, 2) + Math.pow(x.left - C.left, 2)) / Math.sqrt(Math.pow(x.top - $.top, 2) + Math.pow(x.left - $.left, 2)) * re.animation;
      })(m, f, E, o.options)), Ct(s, p) || (l.prevFromRect = p, l.prevToRect = s, c || (c = o.options.animation), o.animate(l, m, s, c)), c && (a = !0, r = Math.max(r, c), clearTimeout(l.animationResetTimer), l.animationResetTimer = setTimeout(function() {
        l.animationTime = 0, l.prevFromRect = null, l.fromRect = null, l.prevToRect = null, l.thisAnimationDuration = null;
      }, c), l.thisAnimationDuration = c);
    }), clearTimeout(e), a ? e = setTimeout(function() {
      typeof n == "function" && n();
    }, r) : typeof n == "function" && n(), t = [];
  }, animate: function(n, o, a, r) {
    if (r) {
      w(n, "transition", ""), w(n, "transform", "");
      var i = $e(this.el), c = i && i.a, l = i && i.d, p = (o.left - a.left) / (c || 1), s = (o.top - a.top) / (l || 1);
      n.animatingX = !!p, n.animatingY = !!s, w(n, "transform", "translate3d(" + p + "px," + s + "px,0)"), this.forRepaintDummy = (function(f) {
        return f.offsetWidth;
      })(n), w(n, "transition", "transform " + r + "ms" + (this.options.easing ? " " + this.options.easing : "")), w(n, "transform", "translate3d(0,0,0)"), typeof n.animated == "number" && clearTimeout(n.animated), n.animated = setTimeout(function() {
        w(n, "transition", ""), w(n, "transform", ""), n.animated = !1, n.animatingX = !1, n.animatingY = !1;
      }, r);
    }
  } };
}
var Xe = [], _t = { initializeByDefault: !0 }, ot = { mount: function(e) {
  for (var t in _t) _t.hasOwnProperty(t) && !(t in e) && (e[t] = _t[t]);
  Xe.forEach(function(n) {
    if (n.pluginName === e.pluginName) throw "Sortable: Cannot mount plugin ".concat(e.pluginName, " more than once");
  }), Xe.push(e);
}, pluginEvent: function(e, t, n) {
  var o = this;
  this.eventCanceled = !1, n.cancel = function() {
    o.eventCanceled = !0;
  };
  var a = e + "Global";
  Xe.forEach(function(r) {
    t[r.pluginName] && (t[r.pluginName][a] && t[r.pluginName][a](Te({ sortable: t }, n)), t.options[r.pluginName] && t[r.pluginName][e] && t[r.pluginName][e](Te({ sortable: t }, n)));
  });
}, initializePlugins: function(e, t, n, o) {
  for (var a in Xe.forEach(function(i) {
    var c = i.pluginName;
    if (e.options[c] || i.initializeByDefault) {
      var l = new i(e, t, e.options);
      l.sortable = e, l.options = e.options, e[c] = l, _e(n, l.defaults);
    }
  }), e.options) if (e.options.hasOwnProperty(a)) {
    var r = this.modifyOption(e, a, e.options[a]);
    r !== void 0 && (e.options[a] = r);
  }
}, getEventProperties: function(e, t) {
  var n = {};
  return Xe.forEach(function(o) {
    typeof o.eventProperties == "function" && _e(n, o.eventProperties.call(t[o.pluginName], e));
  }), n;
}, modifyOption: function(e, t, n) {
  var o;
  return Xe.forEach(function(a) {
    e[a.pluginName] && a.optionListeners && typeof a.optionListeners[t] == "function" && (o = a.optionListeners[t].call(e[a.pluginName], n));
  }), o;
} }, Yn = ["evt"], ae = function(e, t) {
  var n = arguments.length > 2 && arguments[2] !== void 0 ? arguments[2] : {}, o = n.evt, a = zn(n, Yn);
  ot.pluginEvent.bind(b)(e, t, Te({ dragEl: u, parentEl: F, ghostEl: S, rootEl: k, nextEl: Fe, lastDownEl: vt, cloneEl: H, cloneHidden: Re, dragStarted: Ue, putSortable: V, activeSortable: b.active, originalEvent: o, oldIndex: qe, oldDraggableIndex: tt, newIndex: ce, newDraggableIndex: Ne, hideGhostForTarget: wn, unhideGhostForTarget: yn, cloneNowHidden: function() {
    Re = !0;
  }, cloneNowShown: function() {
    Re = !1;
  }, dispatchSortableEvent: function(r) {
    Q({ sortable: t, name: r, originalEvent: o });
  } }, a));
};
function Q(e) {
  (function(t) {
    var n = t.sortable, o = t.rootEl, a = t.name, r = t.targetEl, i = t.cloneEl, c = t.toEl, l = t.fromEl, p = t.oldIndex, s = t.newIndex, f = t.oldDraggableIndex, E = t.newDraggableIndex, m = t.originalEvent, I = t.putSortable, C = t.extraEventProperties;
    if (n = n || o && o[ue]) {
      var x, $ = n.options, re = "on" + a.charAt(0).toUpperCase() + a.substr(1);
      !window.CustomEvent || Oe || rt ? (x = document.createEvent("Event")).initEvent(a, !0, !0) : x = new CustomEvent(a, { bubbles: !0, cancelable: !0 }), x.to = c || o, x.from = l || o, x.item = r || o, x.clone = i, x.oldIndex = p, x.newIndex = s, x.oldDraggableIndex = f, x.newDraggableIndex = E, x.originalEvent = m, x.pullMode = I ? I.lastPutMode : void 0;
      var G = Te(Te({}, C), ot.getEventProperties(a, n));
      for (var U in G) x[U] = G[U];
      o && o.dispatchEvent(x), $[re] && $[re].call(n, x);
    }
  })(Te({ putSortable: V, cloneEl: H, targetEl: u, rootEl: k, oldIndex: qe, oldDraggableIndex: tt, newIndex: ce, newDraggableIndex: Ne }, e));
}
var u, F, S, k, Fe, vt, H, Re, qe, ce, tt, Ne, st, V, Ae, ge, Dt, Ot, tn, nn, Ue, Ye, Ge, ct, K, je = !1, wt = !1, yt = [], Ke = !1, ut = !1, Pt = [], Lt = !1, dt = [], Tt = typeof document < "u", ht = dn, on = rt || Oe ? "cssFloat" : "float", jn = Tt && !hn && !dn && "draggable" in document.createElement("div"), vn = (function() {
  if (Tt) {
    if (Oe) return !1;
    var e = document.createElement("x");
    return e.style.cssText = "pointer-events:auto", e.style.pointerEvents === "auto";
  }
})(), gn = function(e, t) {
  var n = w(e), o = parseInt(n.width) - parseInt(n.paddingLeft) - parseInt(n.paddingRight) - parseInt(n.borderLeftWidth) - parseInt(n.borderRightWidth), a = We(e, 0, t), r = We(e, 1, t), i = a && w(a), c = r && w(r), l = i && parseInt(i.marginLeft) + parseInt(i.marginRight) + Y(a).width, p = c && parseInt(c.marginLeft) + parseInt(c.marginRight) + Y(r).width;
  if (n.display === "flex") return n.flexDirection === "column" || n.flexDirection === "column-reverse" ? "vertical" : "horizontal";
  if (n.display === "grid") return n.gridTemplateColumns.split(" ").length <= 1 ? "vertical" : "horizontal";
  if (a && i.float && i.float !== "none") {
    var s = i.float === "left" ? "left" : "right";
    return !r || c.clear !== "both" && c.clear !== s ? "horizontal" : "vertical";
  }
  return a && (i.display === "block" || i.display === "flex" || i.display === "table" || i.display === "grid" || l >= o && n[on] === "none" || r && n[on] === "none" && l + p > o) ? "vertical" : "horizontal";
}, bn = function(e) {
  function t(a, r) {
    return function(i, c, l, p) {
      var s = i.options.group.name && c.options.group.name && i.options.group.name === c.options.group.name;
      if (a == null && (r || s)) return !0;
      if (a == null || a === !1) return !1;
      if (r && a === "clone") return a;
      if (typeof a == "function") return t(a(i, c, l, p), r)(i, c, l, p);
      var f = (r ? i : c).options.group.name;
      return a === !0 || typeof a == "string" && a === f || a.join && a.indexOf(f) > -1;
    };
  }
  var n = {}, o = e.group;
  o && Ht(o) == "object" || (o = { name: o }), n.name = o.name, n.checkPull = t(o.pull, !0), n.checkPut = t(o.put), n.revertClone = o.revertClone, e.group = n;
}, wn = function() {
  !vn && S && w(S, "display", "none");
}, yn = function() {
  !vn && S && w(S, "display", "");
};
Tt && !hn && document.addEventListener("click", function(e) {
  if (wt) return e.preventDefault(), e.stopPropagation && e.stopPropagation(), e.stopImmediatePropagation && e.stopImmediatePropagation(), wt = !1, !1;
}, !0);
var Be = function(e) {
  if (u) {
    e = e.touches ? e.touches[0] : e;
    var t = (a = e.clientX, r = e.clientY, yt.some(function(c) {
      var l = c[ue].options.emptyInsertThreshold;
      if (l && !zt(c)) {
        var p = Y(c), s = a >= p.left - l && a <= p.right + l, f = r >= p.top - l && r <= p.bottom + l;
        return s && f ? i = c : void 0;
      }
    }), i);
    if (t) {
      var n = {};
      for (var o in e) e.hasOwnProperty(o) && (n[o] = e[o]);
      n.target = n.rootEl = t, n.preventDefault = void 0, n.stopPropagation = void 0, t[ue]._onDragOver(n);
    }
  }
  var a, r, i;
}, qn = function(e) {
  u && u.parentNode[ue]._isOutsideThisEl(e.target);
};
function b(e, t) {
  if (!e || !e.nodeType || e.nodeType !== 1) throw "Sortable: `el` must be an HTMLElement, not ".concat({}.toString.call(e));
  this.el = e, this.options = t = _e({}, t), e[ue] = this;
  var n = { group: null, sort: !0, disabled: !1, store: null, handle: null, draggable: /^[uo]l$/i.test(e.nodeName) ? ">li" : ">*", swapThreshold: 1, invertSwap: !1, invertedSwapThreshold: null, removeCloneOnHide: !0, direction: function() {
    return gn(e, this.options);
  }, ghostClass: "sortable-ghost", chosenClass: "sortable-chosen", dragClass: "sortable-drag", ignore: "a, img", filter: null, preventOnFilter: !0, animation: 0, easing: null, setData: function(r, i) {
    r.setData("Text", i.textContent);
  }, dropBubble: !1, dragoverBubble: !1, dataIdAttr: "data-id", delay: 0, delayOnTouchOnly: !1, touchStartThreshold: (Number.parseInt ? Number : window).parseInt(window.devicePixelRatio, 10) || 1, forceFallback: !1, fallbackClass: "sortable-fallback", fallbackOnBody: !1, fallbackTolerance: 0, fallbackOffset: { x: 0, y: 0 }, supportPointer: b.supportPointer !== !1 && "PointerEvent" in window && !Qe, emptyInsertThreshold: 5 };
  for (var o in ot.initializePlugins(this, e, n), n) !(o in t) && (t[o] = n[o]);
  for (var a in bn(t), this) a.charAt(0) === "_" && typeof this[a] == "function" && (this[a] = this[a].bind(this));
  this.nativeDraggable = !t.forceFallback && jn, this.nativeDraggable && (this.options.touchStartThreshold = 1), t.supportPointer ? M(e, "pointerdown", this._onTapStart) : (M(e, "mousedown", this._onTapStart), M(e, "touchstart", this._onTapStart)), this.nativeDraggable && (M(e, "dragover", this), M(e, "dragenter", this)), yt.push(this.el), t.store && t.store.get && this.sort(t.store.get(this) || []), _e(this, Xn());
}
function pt(e, t, n, o, a, r, i, c) {
  var l, p, s = e[ue], f = s.options.onMove;
  return !window.CustomEvent || Oe || rt ? (l = document.createEvent("Event")).initEvent("move", !0, !0) : l = new CustomEvent("move", { bubbles: !0, cancelable: !0 }), l.to = t, l.from = e, l.dragged = n, l.draggedRect = o, l.related = a || t, l.relatedRect = r || Y(t), l.willInsertAfter = c, l.originalEvent = i, e.dispatchEvent(l), f && (p = f.call(s, l, i)), p;
}
function Mt(e) {
  e.draggable = !1;
}
function $n() {
  Lt = !1;
}
function Wn(e) {
  for (var t = e.tagName + e.className + e.src + e.href + e.textContent, n = t.length, o = 0; n--; ) o += t.charCodeAt(n);
  return o.toString(36);
}
function ft(e) {
  return setTimeout(e, 0);
}
function Nt(e) {
  return clearTimeout(e);
}
b.prototype = { constructor: b, _isOutsideThisEl: function(e) {
  this.el.contains(e) || e === this.el || (Ye = null);
}, _getDirection: function(e, t) {
  return typeof this.options.direction == "function" ? this.options.direction.call(this, e, t, u) : this.options.direction;
}, _onTapStart: function(e) {
  if (e.cancelable) {
    var t = this, n = this.el, o = this.options, a = o.preventOnFilter, r = e.type, i = e.touches && e.touches[0] || e.pointerType && e.pointerType === "touch" && e, c = (i || e).target, l = e.target.shadowRoot && (e.path && e.path[0] || e.composedPath && e.composedPath()[0]) || c, p = o.filter;
    if ((function(s) {
      dt.length = 0;
      for (var f = s.getElementsByTagName("input"), E = f.length; E--; ) {
        var m = f[E];
        m.checked && dt.push(m);
      }
    })(n), !u && !(/mousedown|pointerdown/.test(r) && e.button !== 0 || o.disabled) && !l.isContentEditable && (this.nativeDraggable || !Qe || !c || c.tagName.toUpperCase() !== "SELECT") && !((c = be(c, o.draggable, n, !1)) && c.animated || vt === c)) {
      if (qe = fe(c), tt = fe(c, o.draggable), typeof p == "function") {
        if (p.call(this, e, c, this)) return Q({ sortable: t, rootEl: l, name: "filter", targetEl: c, toEl: n, fromEl: n }), ae("filter", t, { evt: e }), void (a && e.cancelable && e.preventDefault());
      } else if (p && (p = p.split(",").some(function(s) {
        if (s = be(l, s.trim(), n, !1)) return Q({ sortable: t, rootEl: s, name: "filter", targetEl: c, fromEl: n, toEl: n }), ae("filter", t, { evt: e }), !0;
      }))) return void (a && e.cancelable && e.preventDefault());
      o.handle && !be(l, o.handle, n, !1) || this._prepareDragStart(e, i, c);
    }
  }
}, _prepareDragStart: function(e, t, n) {
  var o, a = this, r = a.el, i = a.options, c = r.ownerDocument;
  if (n && !u && n.parentNode === r) {
    var l = Y(n);
    if (k = r, F = (u = n).parentNode, Fe = u.nextSibling, vt = n, st = i.group, b.dragged = u, Ae = { target: u, clientX: (t || e).clientX, clientY: (t || e).clientY }, tn = Ae.clientX - l.left, nn = Ae.clientY - l.top, this._lastX = (t || e).clientX, this._lastY = (t || e).clientY, u.style["will-change"] = "all", o = function() {
      ae("delayEnded", a, { evt: e }), b.eventCanceled ? a._onDrop() : (a._disableDelayedDragEvents(), !Gt && a.nativeDraggable && (u.draggable = !0), a._triggerDragStart(e, t), Q({ sortable: a, name: "choose", originalEvent: e }), se(u, i.chosenClass, !0));
    }, i.ignore.split(",").forEach(function(p) {
      Ut(u, p.trim(), Mt);
    }), M(c, "dragover", Be), M(c, "mousemove", Be), M(c, "touchmove", Be), M(c, "mouseup", a._onDrop), M(c, "touchend", a._onDrop), M(c, "touchcancel", a._onDrop), Gt && this.nativeDraggable && (this.options.touchStartThreshold = 4, u.draggable = !0), ae("delayStart", this, { evt: e }), !i.delay || i.delayOnTouchOnly && !t || this.nativeDraggable && (rt || Oe)) o();
    else {
      if (b.eventCanceled) return void this._onDrop();
      M(c, "mouseup", a._disableDelayedDrag), M(c, "touchend", a._disableDelayedDrag), M(c, "touchcancel", a._disableDelayedDrag), M(c, "mousemove", a._delayedDragTouchMoveHandler), M(c, "touchmove", a._delayedDragTouchMoveHandler), i.supportPointer && M(c, "pointermove", a._delayedDragTouchMoveHandler), a._dragStartTimer = setTimeout(o, i.delay);
    }
  }
}, _delayedDragTouchMoveHandler: function(e) {
  var t = e.touches ? e.touches[0] : e;
  Math.max(Math.abs(t.clientX - this._lastX), Math.abs(t.clientY - this._lastY)) >= Math.floor(this.options.touchStartThreshold / (this.nativeDraggable && window.devicePixelRatio || 1)) && this._disableDelayedDrag();
}, _disableDelayedDrag: function() {
  u && Mt(u), clearTimeout(this._dragStartTimer), this._disableDelayedDragEvents();
}, _disableDelayedDragEvents: function() {
  var e = this.el.ownerDocument;
  D(e, "mouseup", this._disableDelayedDrag), D(e, "touchend", this._disableDelayedDrag), D(e, "touchcancel", this._disableDelayedDrag), D(e, "mousemove", this._delayedDragTouchMoveHandler), D(e, "touchmove", this._delayedDragTouchMoveHandler), D(e, "pointermove", this._delayedDragTouchMoveHandler);
}, _triggerDragStart: function(e, t) {
  t = t || e.pointerType == "touch" && e, !this.nativeDraggable || t ? this.options.supportPointer ? M(document, "pointermove", this._onTouchMove) : M(document, t ? "touchmove" : "mousemove", this._onTouchMove) : (M(u, "dragend", this), M(k, "dragstart", this._onDragStart));
  try {
    document.selection ? ft(function() {
      document.selection.empty();
    }) : window.getSelection().removeAllRanges();
  } catch {
  }
}, _dragStarted: function(e, t) {
  if (je = !1, k && u) {
    ae("dragStarted", this, { evt: t }), this.nativeDraggable && M(document, "dragover", qn);
    var n = this.options;
    !e && se(u, n.dragClass, !1), se(u, n.ghostClass, !0), b.active = this, e && this._appendGhost(), Q({ sortable: this, name: "start", originalEvent: t });
  } else this._nulling();
}, _emulateDragOver: function() {
  if (ge) {
    this._lastX = ge.clientX, this._lastY = ge.clientY, wn();
    for (var e = document.elementFromPoint(ge.clientX, ge.clientY), t = e; e && e.shadowRoot && (e = e.shadowRoot.elementFromPoint(ge.clientX, ge.clientY)) !== t; ) t = e;
    if (u.parentNode[ue]._isOutsideThisEl(e), t) do {
      if (t[ue] && t[ue]._onDragOver({ clientX: ge.clientX, clientY: ge.clientY, target: e, rootEl: t }) && !this.options.dragoverBubble)
        break;
      e = t;
    } while (t = t.parentNode);
    yn();
  }
}, _onTouchMove: function(e) {
  if (Ae) {
    var t = this.options, n = t.fallbackTolerance, o = t.fallbackOffset, a = e.touches ? e.touches[0] : e, r = S && $e(S, !0), i = S && r && r.a, c = S && r && r.d, l = ht && K && Zt(K), p = (a.clientX - Ae.clientX + o.x) / (i || 1) + (l ? l[0] - Pt[0] : 0) / (i || 1), s = (a.clientY - Ae.clientY + o.y) / (c || 1) + (l ? l[1] - Pt[1] : 0) / (c || 1);
    if (!b.active && !je) {
      if (n && Math.max(Math.abs(a.clientX - this._lastX), Math.abs(a.clientY - this._lastY)) < n) return;
      this._onDragStart(e, !0);
    }
    if (S) {
      r ? (r.e += p - (Dt || 0), r.f += s - (Ot || 0)) : r = { a: 1, b: 0, c: 0, d: 1, e: p, f: s };
      var f = "matrix(".concat(r.a, ",").concat(r.b, ",").concat(r.c, ",").concat(r.d, ",").concat(r.e, ",").concat(r.f, ")");
      w(S, "webkitTransform", f), w(S, "mozTransform", f), w(S, "msTransform", f), w(S, "transform", f), Dt = p, Ot = s, ge = a;
    }
    e.cancelable && e.preventDefault();
  }
}, _appendGhost: function() {
  if (!S) {
    var e = this.options.fallbackOnBody ? document.body : k, t = Y(u, !0, ht, !0, e), n = this.options;
    if (ht) {
      for (K = e; w(K, "position") === "static" && w(K, "transform") === "none" && K !== document; ) K = K.parentNode;
      K !== document.body && K !== document.documentElement ? (K === document && (K = Ee()), t.top += K.scrollTop, t.left += K.scrollLeft) : K = Ee(), Pt = Zt(K);
    }
    se(S = u.cloneNode(!0), n.ghostClass, !1), se(S, n.fallbackClass, !0), se(S, n.dragClass, !0), w(S, "transition", ""), w(S, "transform", ""), w(S, "box-sizing", "border-box"), w(S, "margin", 0), w(S, "top", t.top), w(S, "left", t.left), w(S, "width", t.width), w(S, "height", t.height), w(S, "opacity", "0.8"), w(S, "position", ht ? "absolute" : "fixed"), w(S, "zIndex", "100000"), w(S, "pointerEvents", "none"), b.ghost = S, e.appendChild(S), w(S, "transform-origin", tn / parseInt(S.style.width) * 100 + "% " + nn / parseInt(S.style.height) * 100 + "%");
  }
}, _onDragStart: function(e, t) {
  var n = this, o = e.dataTransfer, a = n.options;
  ae("dragStart", this, { evt: e }), b.eventCanceled ? this._onDrop() : (ae("setupClone", this), b.eventCanceled || ((H = Qt(u)).removeAttribute("id"), H.draggable = !1, H.style["will-change"] = "", this._hideClone(), se(H, this.options.chosenClass, !1), b.clone = H), n.cloneId = ft(function() {
    ae("clone", n), b.eventCanceled || (n.options.removeCloneOnHide || k.insertBefore(H, u), n._hideClone(), Q({ sortable: n, name: "clone" }));
  }), !t && se(u, a.dragClass, !0), t ? (wt = !0, n._loopId = setInterval(n._emulateDragOver, 50)) : (D(document, "mouseup", n._onDrop), D(document, "touchend", n._onDrop), D(document, "touchcancel", n._onDrop), o && (o.effectAllowed = "move", a.setData && a.setData.call(n, o, u)), M(document, "drop", n), w(u, "transform", "translateZ(0)")), je = !0, n._dragStartId = ft(n._dragStarted.bind(n, t, e)), M(document, "selectstart", n), Ue = !0, Qe && w(document.body, "user-select", "none"));
}, _onDragOver: function(e) {
  var t, n, o, a, r = this.el, i = e.target, c = this.options, l = c.group, p = b.active, s = st === l, f = c.sort, E = V || p, m = this, I = !1;
  if (!Lt) {
    if (e.preventDefault !== void 0 && e.cancelable && e.preventDefault(), i = be(i, c.draggable, r, !0), le("dragOver"), b.eventCanceled) return I;
    if (u.contains(e.target) || i.animated && i.animatingX && i.animatingY || m._ignoreWhileAnimating === i) return Z(!1);
    if (wt = !1, p && !c.disabled && (s ? f || (o = F !== k) : V === this || (this.lastPutMode = st.checkPull(this, p, u, e)) && l.checkPut(this, p, u, e))) {
      if (a = this._getDirection(e, i) === "vertical", t = Y(u), le("dragOverValid"), b.eventCanceled) return I;
      if (o) return F = k, ve(), this._hideClone(), le("revert"), b.eventCanceled || (Fe ? k.insertBefore(u, Fe) : k.appendChild(u)), Z(!0);
      var C = zt(r, c.draggable);
      if (!C || (function(O, W, R) {
        var z = Y(zt(R.el, R.options.draggable)), oe = en(R.el, R.options, S), B = 10;
        return W ? O.clientX > oe.right + B || O.clientY > z.bottom && O.clientX > z.left : O.clientY > oe.bottom + B || O.clientX > z.right && O.clientY > z.top;
      })(e, a, this) && !C.animated) {
        if (C === u) return Z(!1);
        if (C && r === e.target && (i = C), i && (n = Y(i)), pt(k, r, u, t, i, n, e, !!i) !== !1) return ve(), C && C.nextSibling ? r.insertBefore(u, C.nextSibling) : r.appendChild(u), F = r, we(), Z(!0);
      } else if (C && (function(O, W, R) {
        var z = Y(We(R.el, 0, R.options, !0)), oe = en(R.el, R.options, S), B = 10;
        return W ? O.clientX < oe.left - B || O.clientY < z.top && O.clientX < z.right : O.clientY < oe.top - B || O.clientY < z.bottom && O.clientX < z.left;
      })(e, a, this)) {
        var x = We(r, 0, c, !0);
        if (x === u) return Z(!1);
        if (n = Y(i = x), pt(k, r, u, t, i, n, e, !1) !== !1) return ve(), r.insertBefore(u, x), F = r, we(), Z(!0);
      } else if (i.parentNode === r) {
        n = Y(i);
        var $, re, G, U = u.parentNode !== r, Ce = !(function(O, W, R) {
          var z = R ? O.left : O.top, oe = R ? O.right : O.bottom, B = R ? O.width : O.height, d = R ? W.left : W.top, v = R ? W.right : W.bottom, h = R ? W.width : W.height;
          return z === d || oe === v || z + B / 2 === d + h / 2;
        })(u.animated && u.toRect || t, i.animated && i.toRect || n, a), Pe = a ? "top" : "left", J = Jt(i, "top", "top") || Jt(u, "top", "top"), he = J ? J.scrollTop : void 0;
        if (Ye !== i && (re = n[Pe], Ke = !1, ut = !Ce && c.invertSwap || U), $ = (function(O, W, R, z, oe, B, d, v) {
          var h = z ? O.clientY : O.clientX, T = z ? R.height : R.width, _ = z ? R.top : R.left, y = z ? R.bottom : R.right, A = !1;
          if (!d) {
            if (v && ct < T * oe) {
              if (!Ke && (Ge === 1 ? h > _ + T * B / 2 : h < y - T * B / 2) && (Ke = !0), Ke) A = !0;
              else if (Ge === 1 ? h < _ + ct : h > y - ct) return -Ge;
            } else if (h > _ + T * (1 - oe) / 2 && h < y - T * (1 - oe) / 2) return (function(ye) {
              return fe(u) < fe(ye) ? 1 : -1;
            })(W);
          }
          return (A = A || d) && (h < _ + T * B / 2 || h > y - T * B / 2) ? h > _ + T / 2 ? 1 : -1 : 0;
        })(e, i, n, a, Ce ? 1 : c.swapThreshold, c.invertedSwapThreshold == null ? c.swapThreshold : c.invertedSwapThreshold, ut, Ye === i), $ !== 0) {
          var j = fe(u);
          do
            j -= $, G = F.children[j];
          while (G && (w(G, "display") === "none" || G === S));
        }
        if ($ === 0 || G === i) return Z(!1);
        Ye = i, Ge = $;
        var ie = i.nextElementSibling, N = !1, ne = pt(k, r, u, t, i, n, e, N = $ === 1);
        if (ne !== !1) return ne !== 1 && ne !== -1 || (N = ne === 1), Lt = !0, setTimeout($n, 30), ve(), N && !ie ? r.appendChild(u) : i.parentNode.insertBefore(u, N ? ie : i), J && mn(J, 0, he - J.scrollTop), F = u.parentNode, re === void 0 || ut || (ct = Math.abs(re - Y(i)[Pe])), we(), Z(!0);
      }
      if (r.contains(u)) return Z(!1);
    }
    return !1;
  }
  function le(O, W) {
    ae(O, m, Te({ evt: e, isOwner: s, axis: a ? "vertical" : "horizontal", revert: o, dragRect: t, targetRect: n, canSort: f, fromSortable: E, target: i, completed: Z, onMove: function(R, z) {
      return pt(k, r, u, t, R, Y(R), e, z);
    }, changed: we }, W));
  }
  function ve() {
    le("dragOverAnimationCapture"), m.captureAnimationState(), m !== E && E.captureAnimationState();
  }
  function Z(O) {
    return le("dragOverCompleted", { insertion: O }), O && (s ? p._hideClone() : p._showClone(m), m !== E && (se(u, V ? V.options.ghostClass : p.options.ghostClass, !1), se(u, c.ghostClass, !0)), V !== m && m !== b.active ? V = m : m === b.active && V && (V = null), E === m && (m._ignoreWhileAnimating = i), m.animateAll(function() {
      le("dragOverAnimationComplete"), m._ignoreWhileAnimating = null;
    }), m !== E && (E.animateAll(), E._ignoreWhileAnimating = null)), (i === u && !u.animated || i === r && !i.animated) && (Ye = null), c.dragoverBubble || e.rootEl || i === document || (u.parentNode[ue]._isOutsideThisEl(e.target), !O && Be(e)), !c.dragoverBubble && e.stopPropagation && e.stopPropagation(), I = !0;
  }
  function we() {
    ce = fe(u), Ne = fe(u, c.draggable), Q({ sortable: m, name: "change", toEl: r, newIndex: ce, newDraggableIndex: Ne, originalEvent: e });
  }
}, _ignoreWhileAnimating: null, _offMoveEvents: function() {
  D(document, "mousemove", this._onTouchMove), D(document, "touchmove", this._onTouchMove), D(document, "pointermove", this._onTouchMove), D(document, "dragover", Be), D(document, "mousemove", Be), D(document, "touchmove", Be);
}, _offUpEvents: function() {
  var e = this.el.ownerDocument;
  D(e, "mouseup", this._onDrop), D(e, "touchend", this._onDrop), D(e, "pointerup", this._onDrop), D(e, "touchcancel", this._onDrop), D(document, "selectstart", this);
}, _onDrop: function(e) {
  var t = this.el, n = this.options;
  ce = fe(u), Ne = fe(u, n.draggable), ae("drop", this, { evt: e }), F = u && u.parentNode, ce = fe(u), Ne = fe(u, n.draggable), b.eventCanceled || (je = !1, ut = !1, Ke = !1, clearInterval(this._loopId), clearTimeout(this._dragStartTimer), Nt(this.cloneId), Nt(this._dragStartId), this.nativeDraggable && (D(document, "drop", this), D(t, "dragstart", this._onDragStart)), this._offMoveEvents(), this._offUpEvents(), Qe && w(document.body, "user-select", ""), w(u, "transform", ""), e && (Ue && (e.cancelable && e.preventDefault(), !n.dropBubble && e.stopPropagation()), S && S.parentNode && S.parentNode.removeChild(S), (k === F || V && V.lastPutMode !== "clone") && H && H.parentNode && H.parentNode.removeChild(H), u && (this.nativeDraggable && D(u, "dragend", this), Mt(u), u.style["will-change"] = "", Ue && !je && se(u, V ? V.options.ghostClass : this.options.ghostClass, !1), se(u, this.options.chosenClass, !1), Q({ sortable: this, name: "unchoose", toEl: F, newIndex: null, newDraggableIndex: null, originalEvent: e }), k !== F ? (ce >= 0 && (Q({ rootEl: F, name: "add", toEl: F, fromEl: k, originalEvent: e }), Q({ sortable: this, name: "remove", toEl: F, originalEvent: e }), Q({ rootEl: F, name: "sort", toEl: F, fromEl: k, originalEvent: e }), Q({ sortable: this, name: "sort", toEl: F, originalEvent: e })), V && V.save()) : ce !== qe && ce >= 0 && (Q({ sortable: this, name: "update", toEl: F, originalEvent: e }), Q({ sortable: this, name: "sort", toEl: F, originalEvent: e })), b.active && (ce != null && ce !== -1 || (ce = qe, Ne = tt), Q({ sortable: this, name: "end", toEl: F, originalEvent: e }), this.save())))), this._nulling();
}, _nulling: function() {
  ae("nulling", this), k = u = F = S = Fe = H = vt = Re = Ae = ge = Ue = ce = Ne = qe = tt = Ye = Ge = V = st = b.dragged = b.ghost = b.clone = b.active = null, dt.forEach(function(e) {
    e.checked = !0;
  }), dt.length = Dt = Ot = 0;
}, handleEvent: function(e) {
  switch (e.type) {
    case "drop":
    case "dragend":
      this._onDrop(e);
      break;
    case "dragenter":
    case "dragover":
      u && (this._onDragOver(e), (function(t) {
        t.dataTransfer && (t.dataTransfer.dropEffect = "move"), t.cancelable && t.preventDefault();
      })(e));
      break;
    case "selectstart":
      e.preventDefault();
  }
}, toArray: function() {
  for (var e, t = [], n = this.el.children, o = 0, a = n.length, r = this.options; o < a; o++) be(e = n[o], r.draggable, this.el, !1) && t.push(e.getAttribute(r.dataIdAttr) || Wn(e));
  return t;
}, sort: function(e, t) {
  var n = {}, o = this.el;
  this.toArray().forEach(function(a, r) {
    var i = o.children[r];
    be(i, this.options.draggable, o, !1) && (n[a] = i);
  }, this), t && this.captureAnimationState(), e.forEach(function(a) {
    n[a] && (o.removeChild(n[a]), o.appendChild(n[a]));
  }), t && this.animateAll();
}, save: function() {
  var e = this.options.store;
  e && e.set && e.set(this);
}, closest: function(e, t) {
  return be(e, t || this.options.draggable, this.el, !1);
}, option: function(e, t) {
  var n = this.options;
  if (t === void 0) return n[e];
  var o = ot.modifyOption(this, e, t);
  n[e] = o !== void 0 ? o : t, e === "group" && bn(n);
}, destroy: function() {
  ae("destroy", this);
  var e = this.el;
  e[ue] = null, D(e, "mousedown", this._onTapStart), D(e, "touchstart", this._onTapStart), D(e, "pointerdown", this._onTapStart), this.nativeDraggable && (D(e, "dragover", this), D(e, "dragenter", this)), Array.prototype.forEach.call(e.querySelectorAll("[draggable]"), function(t) {
    t.removeAttribute("draggable");
  }), this._onDrop(), this._disableDelayedDragEvents(), yt.splice(yt.indexOf(this.el), 1), this.el = e = null;
}, _hideClone: function() {
  if (!Re) {
    if (ae("hideClone", this), b.eventCanceled) return;
    w(H, "display", "none"), this.options.removeCloneOnHide && H.parentNode && H.parentNode.removeChild(H), Re = !0;
  }
}, _showClone: function(e) {
  if (e.lastPutMode === "clone") {
    if (Re) {
      if (ae("showClone", this), b.eventCanceled) return;
      u.parentNode != k || this.options.group.revertClone ? Fe ? k.insertBefore(H, Fe) : k.appendChild(H) : k.insertBefore(H, u), this.options.group.revertClone && this.animate(u, H), w(H, "display", ""), Re = !1;
    }
  } else this._hideClone();
} }, Tt && M(document, "touchmove", function(e) {
  (b.active || je) && e.cancelable && e.preventDefault();
}), b.utils = { on: M, off: D, css: w, find: Ut, is: function(e, t) {
  return !!be(e, t, e, !1);
}, extend: function(e, t) {
  if (e && t) for (var n in t) t.hasOwnProperty(n) && (e[n] = t[n]);
  return e;
}, throttle: fn, closest: be, toggleClass: se, clone: Qt, index: fe, nextTick: ft, cancelNextTick: Nt, detectDirection: gn, getChild: We }, b.get = function(e) {
  return e[ue];
}, b.mount = function() {
  for (var e = arguments.length, t = new Array(e), n = 0; n < e; n++) t[n] = arguments[n];
  t[0].constructor === Array && (t = t[0]), t.forEach(function(o) {
    if (!o.prototype || !o.prototype.constructor) throw "Sortable: Mounted plugin must be a constructor function, not ".concat({}.toString.call(o));
    o.utils && (b.utils = Te(Te({}, b.utils), o.utils)), ot.mount(o);
  });
}, b.create = function(e, t) {
  return new b(e, t);
}, b.version = "1.15.2";
var Je, Xt, Rt, It, St, Ze, X = [], Yt = !1;
function gt() {
  X.forEach(function(e) {
    clearInterval(e.pid);
  }), X = [];
}
function an() {
  clearInterval(Ze);
}
var kt = fn(function(e, t, n, o) {
  if (t.scroll) {
    var a, r = (e.touches ? e.touches[0] : e).clientX, i = (e.touches ? e.touches[0] : e).clientY, c = t.scrollSensitivity, l = t.scrollSpeed, p = Ee(), s = !1;
    Xt !== n && (Xt = n, gt(), Je = t.scroll, a = t.scrollFn, Je === !0 && (Je = Ie(n, !0)));
    var f = 0, E = Je;
    do {
      var m = E, I = Y(m), C = I.top, x = I.bottom, $ = I.left, re = I.right, G = I.width, U = I.height, Ce = void 0, Pe = void 0, J = m.scrollWidth, he = m.scrollHeight, j = w(m), ie = m.scrollLeft, N = m.scrollTop;
      m === p ? (Ce = G < J && (j.overflowX === "auto" || j.overflowX === "scroll" || j.overflowX === "visible"), Pe = U < he && (j.overflowY === "auto" || j.overflowY === "scroll" || j.overflowY === "visible")) : (Ce = G < J && (j.overflowX === "auto" || j.overflowX === "scroll"), Pe = U < he && (j.overflowY === "auto" || j.overflowY === "scroll"));
      var ne = Ce && (Math.abs(re - r) <= c && ie + G < J) - (Math.abs($ - r) <= c && !!ie), le = Pe && (Math.abs(x - i) <= c && N + U < he) - (Math.abs(C - i) <= c && !!N);
      if (!X[f]) for (var ve = 0; ve <= f; ve++) X[ve] || (X[ve] = {});
      X[f].vx == ne && X[f].vy == le && X[f].el === m || (X[f].el = m, X[f].vx = ne, X[f].vy = le, clearInterval(X[f].pid), ne == 0 && le == 0 || (s = !0, X[f].pid = setInterval((function() {
        o && this.layer === 0 && b.active._onTouchMove(St);
        var Z = X[this.layer].vy ? X[this.layer].vy * l : 0, we = X[this.layer].vx ? X[this.layer].vx * l : 0;
        typeof a == "function" && a.call(b.dragged.parentNode[ue], we, Z, e, St, X[this.layer].el) !== "continue" || mn(X[this.layer].el, we, Z);
      }).bind({ layer: f }), 24))), f++;
    } while (t.bubbleScroll && E !== p && (E = Ie(E, !1)));
    Yt = s;
  }
}, 30), rn = function(e) {
  var t = e.originalEvent, n = e.putSortable, o = e.dragEl, a = e.activeSortable, r = e.dispatchSortableEvent, i = e.hideGhostForTarget, c = e.unhideGhostForTarget;
  if (t) {
    var l = n || a;
    i();
    var p = t.changedTouches && t.changedTouches.length ? t.changedTouches[0] : t, s = document.elementFromPoint(p.clientX, p.clientY);
    c(), l && !l.el.contains(s) && (r("spill"), this.onSpill({ dragEl: o, putSortable: n }));
  }
};
function At() {
}
function Bt() {
}
function Vn(e, t, n = {}) {
  let o;
  const { document: a = Fn, ...r } = n, i = { onUpdate: (s) => {
    (function(f, E, m) {
      const I = En(f), C = I ? [...xt(f)] : xt(f);
      if (m >= 0 && m < C.length) {
        const x = C.splice(E, 1)[0];
        He(() => {
          C.splice(m, 0, x), I && (f.value = C);
        });
      }
    })(t, s.oldIndex, s.newIndex);
  } }, c = () => {
    const s = typeof e == "string" ? a?.querySelector(e) : (function(f) {
      var E;
      const m = xt(f);
      return (E = m?.$el) != null ? E : m;
    })(e);
    s && o === void 0 && (o = new b(s, { ...i, ...r }));
  }, l = () => {
    o?.destroy(), o = void 0;
  };
  var p;
  return Bn(c), p = l, Sn() && Tn(p), { stop: l, start: c, option: (s, f) => {
    if (f === void 0) return o?.option(s);
    o?.option(s, f);
  } };
}
function Gn() {
  const e = qt("MaProTableOptions"), { renderPlugins: t = [] } = e?.value?.provider ?? { renderPlugins: [] };
  return { getPluginByName: (n) => t.find((o) => o.name === n), getPlugins: () => t, addPlugin: (n) => {
    t.find((o) => o.name === n.name) || t.push(n);
  }, removePlugin: (n) => {
    const o = t.findIndex((a) => a.name === n);
    o !== -1 && t.splice(o, 1);
  } };
}
At.prototype = { startIndex: null, dragStart: function(e) {
  var t = e.oldDraggableIndex;
  this.startIndex = t;
}, onSpill: function(e) {
  var t = e.dragEl, n = e.putSortable;
  this.sortable.captureAnimationState(), n && n.captureAnimationState();
  var o = We(this.sortable.el, this.startIndex, this.options);
  o ? this.sortable.el.insertBefore(t, o) : this.sortable.el.appendChild(t), this.sortable.animateAll(), n && n.animateAll();
}, drop: rn }, _e(At, { pluginName: "revertOnSpill" }), Bt.prototype = { onSpill: function(e) {
  var t = e.dragEl, n = e.putSortable || this.sortable;
  n.captureAnimationState(), t.parentNode && t.parentNode.removeChild(t), n.animateAll();
}, drop: rn }, _e(Bt, { pluginName: "removeOnSpill" }), b.mount(new function() {
  function e() {
    for (var t in this.defaults = { scroll: !0, forceAutoScrollFallback: !1, scrollSensitivity: 30, scrollSpeed: 10, bubbleScroll: !0 }, this) t.charAt(0) === "_" && typeof this[t] == "function" && (this[t] = this[t].bind(this));
  }
  return e.prototype = { dragStarted: function(t) {
    var n = t.originalEvent;
    this.sortable.nativeDraggable ? M(document, "dragover", this._handleAutoScroll) : this.options.supportPointer ? M(document, "pointermove", this._handleFallbackAutoScroll) : n.touches ? M(document, "touchmove", this._handleFallbackAutoScroll) : M(document, "mousemove", this._handleFallbackAutoScroll);
  }, dragOverCompleted: function(t) {
    var n = t.originalEvent;
    this.options.dragOverBubble || n.rootEl || this._handleAutoScroll(n);
  }, drop: function() {
    this.sortable.nativeDraggable ? D(document, "dragover", this._handleAutoScroll) : (D(document, "pointermove", this._handleFallbackAutoScroll), D(document, "touchmove", this._handleFallbackAutoScroll), D(document, "mousemove", this._handleFallbackAutoScroll)), an(), gt(), clearTimeout(et), et = void 0;
  }, nulling: function() {
    St = Xt = Je = Yt = Ze = Rt = It = null, X.length = 0;
  }, _handleFallbackAutoScroll: function(t) {
    this._handleAutoScroll(t, !0);
  }, _handleAutoScroll: function(t, n) {
    var o = this, a = (t.touches ? t.touches[0] : t).clientX, r = (t.touches ? t.touches[0] : t).clientY, i = document.elementFromPoint(a, r);
    if (St = t, n || this.options.forceAutoScrollFallback || rt || Oe || Qe) {
      kt(t, this.options, i, n);
      var c = Ie(i, !0);
      !Yt || Ze && a === Rt && r === It || (Ze && an(), Ze = setInterval(function() {
        var l = Ie(document.elementFromPoint(a, r), !0);
        l !== c && (c = l, gt()), kt(t, o.options, l, n);
      }, 10), Rt = a, It = r);
    } else {
      if (!this.options.bubbleScroll || Ie(i, !0) === Ee()) return void gt();
      kt(t, this.options, Ie(i, !1), !1);
    }
  } }, _e(e, { pluginName: "scroll", initializeByDefault: !0 });
}()), b.mount(Bt, At);
const ke = (e, t) => {
  const n = e.__vccOpts || e;
  for (const [o, a] of t) n[o] = a;
  return n;
}, Kn = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, Un = ke({ name: "IcBaselineDragIndicator" }, [["render", function(e, t, n, o, a, r) {
  return te(), xe("svg", Kn, [...t[0] || (t[0] = [de("path", { fill: "currentColor", d: "M11 18c0 1.1-.9 2-2 2s-2-.9-2-2s.9-2 2-2s2 .9 2 2m-2-8c-1.1 0-2 .9-2 2s.9 2 2 2s2-.9 2-2s-.9-2-2-2m0-6c-1.1 0-2 .9-2 2s.9 2 2 2s2-.9 2-2s-.9-2-2-2m6 4c1.1 0 2-.9 2-2s-.9-2-2-2s-2 .9-2 2s.9 2 2 2m0 2c-1.1 0-2 .9-2 2s.9 2 2 2s2-.9 2-2s-.9-2-2-2m0 6c-1.1 0-2 .9-2 2s.9 2 2 2s2-.9 2-2s-.9-2-2-2" }, null, -1)])]);
}]]), Jn = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, ln = ke({ name: "RiMoreLine" }, [["render", function(e, t, n, o, a, r) {
  return te(), xe("svg", Jn, [...t[0] || (t[0] = [de("path", { fill: "currentColor", d: "M4.5 10.5c-.825 0-1.5.675-1.5 1.5s.675 1.5 1.5 1.5S6 12.825 6 12s-.675-1.5-1.5-1.5m15 0c-.825 0-1.5.675-1.5 1.5s.675 1.5 1.5 1.5S21 12.825 21 12s-.675-1.5-1.5-1.5m-7.5 0c-.825 0-1.5.675-1.5 1.5s.675 1.5 1.5 1.5s1.5-.675 1.5-1.5s-.675-1.5-1.5-1.5" }, null, -1)])]);
}]]);
function mt(e) {
  return typeof e == "function" || Object.prototype.toString.call(e) === "[object Object]" && !Pn(e);
}
const sn = at({ name: "MaProTable", props: { options: { type: Object, default: () => ({ tableOptions: {}, searchOptions: {}, searchFormOptions: {} }) }, schema: { type: Object, default: () => ({ searchItems: [], tableColumns: [] }) } }, emits: ["row-drag-sort", "search-submit", "search-reset"], setup(e, { slots: t, emit: n, expose: o }) {
  const a = qt("MaProTableOptions"), r = lt(() => {
    const d = [];
    return Wt(a.value.provider.toolbars, (v) => v.order ?? 0).map((v) => {
      (me(v.show) ? v.show : () => v.show !== !1)() && d.push(v);
    }), d;
  }), i = ee([]);
  ee([]);
  const c = ee(!1), l = `_${Math.floor(1e5 * Math.random() + 2e4 * Math.random() + 5e3 * Math.random())}`, p = cn(), s = ee(e.options), f = ee(e.schema), E = ee(f.value?.tableColumns ?? []), m = ee(s.value?.requestOptions ?? {}), I = ee(!0), C = ee(s.value?.requestOptions?.requestParams ?? {}), x = xn([]), $ = ee(), re = lt(() => m.value?.autoRequest ?? !0), G = async () => {
    const { pageName: d = "page", sizeName: v = "page_size", size: h = 20 } = s.value?.requestOptions?.requestPage ?? {};
    C.value[d] = 1, C.value[v] = h, $.value = { pageName: d, sizeName: v, size: h }, await He(() => j(ie()?.getSearchForm?.() ?? {})), re.value && N().setPagination({ defaultPageSize: $.value?.size, pageSizes: [20, 50, 100], onChange: async (T, _) => {
      C.value[d] = T, C.value[v] = _, await he(), Pe();
    } });
  }, U = ee([]), { actionBtnPosition: Ce = "auto" } = s.value, Pe = () => {
    const { tableOptions: d } = s.value, v = me(d?.rowKey) ? d?.rowKey?.({}) : d?.rowKey ?? "id", h = N()?.getElTableRef()?.store?.states;
    if (i.value.length > 0 && h.data.value) {
      const T = i.value.filter((y) => h.data.value.find((A) => y[v] === A[v])), _ = N().getElTableRef();
      T.map((y) => _?.toggleRowSelection?.(y, !0));
    }
  }, J = lt(() => (() => {
    const { header: d, toolbar: v } = s.value;
    return { headerShowFun: typeof d?.show == "function" ? d.show : () => d?.show !== !1, toolbarShowFun: typeof v == "function" ? v : () => v !== !1, searchIsShow: ie()?.getShowState?.() ?? !0 };
  })()), he = async () => {
    if ((m.value?.autoRequest ?? 1) || (m.value.autoRequest = !0, await G()), m.value?.api) if (re.value) {
      const { response: d, data: v, total: h } = await (async () => new Promise((T, _) => {
        N().setLoadingState(!0), m.value?.api(C.value).then((y) => {
          const A = y.data[m.value?.response?.dataKey ?? "list"] ?? [], ye = y.data[m.value?.response?.totalKey ?? "total"] ?? 0;
          N().setLoadingState(!1), T({ response: y.data, data: A, total: ye });
        }).catch(() => {
          N().setLoadingState(!1), _({ response: null, data: [], total: 0 });
        });
      }))();
      N().setData(m.value?.responseDataHandler?.(d) ?? v), h && h > 0 ? (N().setOptions({ showPagination: !0 }), N().setPagination(Object.assign(s.value?.tableOptions?.pagination ?? {}, { total: h }))) : N().setOptions({ showPagination: !1 }), x.value = v, await ne();
    } else x.value = [];
    else {
      const d = s.value?.tableOptions?.data ?? [];
      N().setData(d), x.value = d, await ne();
    }
  }, j = async (d, v = !1) => {
    C.value = Object.assign(C.value, d), v && await he();
  }, ie = () => p?.proxy?.$refs[`MaSearchRef${l}`], N = () => p?.proxy?.$refs[`MaTableRef${l}`], ne = async () => {
    await He();
    await new Promise((d) => {
      requestAnimationFrame(() => {
        requestAnimationFrame(d);
      });
    });
    const d = document.querySelector(`.ma-pro-table .mine-ptt${l} .ma-pagination`);
    if (d?.classList?.add("no-print"), s.value?.tableOptions?.adaption ?? 1) {
      const { headerShowFun: v, toolbarShowFun: h } = J.value, T = document.querySelector(`.ma-pro-table .ma-pro-table-search${l}`)?.offsetHeight ?? 0, _ = document.querySelector(`.ma-pro-table .ma-pro-table-header${l}`)?.offsetHeight ?? 0, y = document.querySelector(`.ma-pro-table .ma-pro-table-tool${l}`)?.offsetHeight ?? 0, A = d?.offsetHeight ?? -35;
      N().setOptions({ adaptionOffsetBottom: (f.value?.searchItems?.length > 0 && ie().getShowState() ? T : -12) + (v() ? _ + 30 : 0) + (h() ? y + 10 : 0) + A + (s?.value?.adaptionOffsetBottom ?? 0) + 16 });
    }
    document.body.clientWidth < 1e3 ? N()?.setPagination({ size: "small", layout: "prev, pager, next, sizes" }) : N()?.setPagination({ size: "default", layout: void 0 });
  }, le = () => g("div", null, [t.actions?.()]), ve = () => {
    const { header: d } = s.value, { headerShowFun: v } = J.value;
    return g(Me, null, [v() && g("div", { className: `mine-card ma-pro-table-header ma-pro-table-header${l}` }, [t.tableHeader?.() ?? g(Me, null, [g("div", { className: "ma-pro-table-header-title" }, [t.headerTitle?.() ?? g(Me, null, [g("div", { className: "main-title" }, [me(d?.mainTitle) ? d.mainTitle() : d?.mainTitle ?? "表格主标题"]), g("div", { className: "secondary-title" }, [me(d?.subTitle) ? d.subTitle() : d?.subTitle ?? ""])])]), g("div", { className: "ma-pro-table-header-actions" }, [["auto", "header"].includes(Ce) && le(), t.headerRight?.()])])])]);
  }, Z = () => {
    const { selection: d, toolStates: v } = s.value, h = lt(() => (me(d?.selectedText) ? d.selectedText() : d?.selectedText ?? "已选择 {number} 项").replace("{number}", i.value.length.toString())), { headerShowFun: T, toolbarShowFun: _ } = J.value;
    return g("div", { className: `ma-pro-table-toolbar ma-pro-table-tool${l}` }, [g("div", { className: "ma-pro-table-toolbar-content" }, [t.toolbarLeft?.(), (!T() || Ce === "table") && _() && le(), d && (d?.crossPage ?? !1) && g("div", { class: "ma-pro-table-selection-all" }, [h.value, g(L("el-link"), { underline: "never", type: "primary", onClick: () => {
      N()?.getElTableRef()?.clearSelection?.(), i.value = [];
    } }, { default: () => [me(d?.clearText) ? d.clearText() : d?.clearText ?? "清除选择"] })])]), g("div", null, [t.beforeToolbar?.(), t.toolbar?.() ?? g(Me, null, [r.value.filter((y) => {
      if (!v) return !0;
      const A = v[y.name] ?? void 0;
      return A === void 0 || (typeof A == "function" ? A?.() : A);
    }).map((y) => Ft(y.render(), { proxy: B.value }))]), t.afterToolbar?.()])]);
  }, we = (d, v) => {
    d.map((h, T) => {
      const _ = me(h?.prop) ? h.prop(T) : h?.prop ?? "";
      if ((me(h?.isRender) ? h.isRender() : h?.isRender ?? !0) || d.splice(T, 1), h?.children?.length > 0) we(h.children, v);
      else if (h?.cellRenderTo) {
        const y = v(h.cellRenderTo.name);
        y && (h.cellRenderTo?.props ? h.cellRenderTo?.props?.prop || (h.cellRenderTo.props.prop = _) : h.cellRenderTo.props = { prop: _ }, h.cellRender = (A) => y.render(A, h.cellRenderTo.props, B.value));
      }
      h.cellRenderPro && (h.cellRender = (y) => h.cellRenderPro(y, B.value)), h.headerRenderPro && (h.headerRender = (y) => h.headerRenderPro(y, B.value));
    });
  }, O = () => {
    const d = E.value.find((_) => _?.type === "sort"), v = E.value.find((_) => _?.type === "operation"), h = E.value.find((_) => _?.type === "selection"), T = E.value.find((_) => _?.type === "index");
    d && (d?.label || d?.headerRender || (d.label = "行排序"), d.width = d?.width ?? "50px", d.showOverflowTooltip = !1, d.cellRender = () => g("div", { className: "mine-cell-flex-center mine-cursor-resize" }, [g(Un, null, null)])), v && (v?.label || v?.headerRender || (v.label = "操作"), v.showOverflowTooltip = !1, v?.cellRender || (v.cellRender = (_) => ((y, A) => {
      const { type: ye = "auto", fold: Et = 1 } = A?.operationConfigure ?? {}, ze = (P) => g(Me, null, [P?.icon && a.value.provider?.icon && Ft(a.value.provider.icon, { style: "margin-right: 2px;", name: me(P.icon) ? P.icon(y) : P.icon }), me(P.text) ? P.text(y) : P?.text ?? "unknown"]), Le = (P, q) => {
        let pe;
        return (P?.show?.(q) ?? !0) && g(L("el-link"), $t({ underline: "never" }, P?.linkProps, { disabled: P?.disabled?.(q) ?? !1, onClick: (it) => P?.onClick?.(q, B.value, it) }), mt(pe = ze(P)) ? pe : { default: () => [pe] });
      }, Ve = (P, q) => {
        let pe;
        const it = P?.disabled?.(q) ?? !1;
        return g(L("el-dropdown-item"), { disabled: it, command: P }, { default: () => [g(L("el-link"), $t({ underline: "never" }, P?.linkProps, { disabled: it }), mt(pe = ze(P)) ? pe : { default: () => [pe] })] });
      };
      if (ye === "auto") {
        const P = [];
        return g("div", { className: "mine-operation-scroll" }, [U.value.map((q, pe) => pe + 1 <= Et ? q?.show?.(y) ?? 1 ? Le(q, y) : null : ((q?.show?.(y) ?? 1) && P.push(q), null)), P.length > 0 && g(L("el-dropdown"), { "hide-on-click": !1, onCommand: (q) => q.onClick?.(y, B.value) }, { default: () => [g(L("el-link"), { underline: "never" }, { default: () => [g(ln, null, null)] })], dropdown: () => {
          let q;
          return g(L("el-dropdown-menu"), null, mt(q = P.map((pe) => pe?.show?.(y) ?? 1 ? Ve(pe, y) : null)) ? q : { default: () => [q] });
        } })]);
      }
      return ye === "dropdown" ? g("div", { className: "mine-operation-scroll" }, [g(L("el-dropdown"), { "hide-on-click": !1, onCommand: (P) => P.onClick?.(y, B.value) }, { default: () => [g(L("el-link"), { underline: "never" }, { default: () => [g(ln, null, null)] })], dropdown: () => {
        let P;
        return g(L("el-dropdown-menu"), null, mt(P = U.value.map((q) => q?.show?.(y) ?? 1 ? Ve(q, y) : null)) ? P : { default: () => [P] });
      } })]) : ye === "tile" ? g("div", { className: "mine-operation-scroll" }, [U.value.map((P) => P?.show?.(y) ?? 1 ? Le(P, y) : null)]) : void 0;
    })(_, v))), h && (h.label = h?.label ?? "多选"), T && (T.label = T?.label ?? "#");
  }, W = () => {
    (s.value?.tableOptions?.adaption ?? 1) && (s.value.tableOptions = Object.assign(s.value?.tableOptions ?? {}, { maxHeight: void 0 })), (() => {
      const { rowContextMenu: d } = s.value;
      (d?.enabled ?? !1) === !0 && a.value.provider?.contextMenu && (s.value.tableOptions || (s.value.tableOptions = {}), s.value.tableOptions.on = s.value.tableOptions?.on ?? {}, s.value.tableOptions.on.onRowContextmenu = (v, h, T) => {
        T.preventDefault(), T.stopPropagation();
        const _ = [];
        d?.items?.map((y, A) => {
          y.onClick = () => {
            y?.onMenuClick?.({ row: v, column: h, proxy: B.value }, T);
          }, _.push(y);
        }), a.value.provider?.contextMenu({ x: T.x, y: T.y, zIndex: 1050, iconFontClass: "", customClass: "mine-contextmenu", items: _ });
      });
    })(), N()?.setOptions({ adaption: s.value?.tableOptions?.adaption ?? !0 }), N()?.setOptions(Object.assign(s.value?.tableOptions ?? {}));
  }, R = () => {
    const { getPluginByName: d } = Gn();
    He(() => {
      const v = E.value?.find((h) => h?.type === "operation");
      U.value = v?.operationConfigure?.actions ?? [], U.value = Wt(U.value, (h) => h.order), we(E.value, d), O(), N()?.setColumns(E.value);
    });
  }, z = () => {
    const { toolbarShowFun: d } = J.value, v = async (h) => {
      const { pageName: T = "page" } = s.value?.requestOptions?.requestPage ?? {};
      Number(C.value[T]) === 1 ? await j(h, !0) : (N()?.setCurrentPage(1), await j(h, !1));
    };
    return g(Me, null, [f.value?.searchItems?.length > 0 && Dn(g("div", { className: `ma-pro-table-search mine-card ma-pro-table-search${l}` }, [g(L("ma-search"), { ref: `MaSearchRef${l}`, options: s.value.searchOptions, "form-options": s.value.searchFormOptions, "search-items": f.value.searchItems, onFold: async () => await ne(), onSearch: async (h) => {
      s.value?.onSearchSubmit && (h = s.value.onSearchSubmit?.(h)), n("search-submit", h), await v(h);
    }, onReset: async (h) => {
      s.value?.onSearchReset && (h = s.value.onSearchReset?.(h)), n("search-reset", h), await v(h);
    } }, { default: t.search?.() ?? void 0, actions: t.searchActions?.() ?? void 0, beforeActions: t.searchBeforeActions?.() ?? void 0, afterActions: t.searchAfterActions?.() ?? void 0 })]), [[On, (s.value.searchOptions?.show ?? !0) && J.value.searchIsShow]]), t.middle?.(), g("div", { className: `mine-card mine-ptt${l}` }, [t.tableTop?.() ?? void 0, d() && Z(), t.tableCranny?.() ?? void 0, I.value && g(L("ma-table"), { id: `ma-table${l}`, class: "ma-pro-table", ref: `MaTableRef${l}`, onSelectionChange: (h) => {
      const { tableOptions: T, selection: _ } = s.value;
      if (_?.crossPage) {
        const y = me(T?.rowKey) ? T?.rowKey?.({}) : T?.rowKey ?? "id";
        i.value.push(...h), i.value = ((A, ye) => {
          const Et = A.reduce((ze, Le) => {
            const Ve = ye ? ye(Le) : Le;
            return ze[Ve] || (ze[Ve] = Le), ze;
          }, {});
          return Object.values(Et);
        })(i.value, (A) => A[y]);
      }
      s.value.selection?.crossPage === !0 && s.value.tableOptions.on.onSelectionChange(i.value);
    }, onSetDataCallback: (h) => x.value = h }, { default: t.default?.() ?? void 0, ...t })])]);
  }, oe = () => g("div", { className: "ma-pro-table" }, [ve(), z()]);
  jt(async () => {
    c.value = !0;
    const d = m.value?.autoRequest ?? !0;
    R(), W(), d && await G(), d && await he(), window.addEventListener("resize", ne), await ne();
    const v = ee(document.querySelector(`.mine-ptt${l} tbody`));
    Cn(() => I.value, (h) => {
      if (h) {
        v.value = document.querySelector(`.mine-ptt${l} tbody`);
        const T = JSON.parse(JSON.stringify(x.value));
        Vn(v, T, { handle: ".mine-cursor-resize", animation: 300, onEnd: async () => {
          await He(() => x.value = T), s.value?.on?.rowDragSort?.(T), n("row-drag-sort", T);
        } });
      }
    }, { immediate: !0 });
  }), _n(() => {
    window.removeEventListener("resize", ne);
  });
  const B = ee({ getSearchRef: () => ie(), getTableRef: () => N(), getElTableStates: () => N()?.getElTableRef()?.store?.states, setTableColumns: (d) => {
    E.value = d, R();
  }, getTableColumns: () => E.value, setSearchForm: (d) => ie()?.setSearchForm?.(d), getSearchForm: () => ie()?.getSearchForm?.(), search: async (d) => await j(Object.assign(ie()?.getSearchForm?.(), d ?? {}), !0), refresh: async () => await he(), getProTableOptions: () => s.value, setProTableOptions: (d) => {
    Object.assign(s.value, d ?? {}), W();
  }, getCurrentId: () => l, requestData: he, changeApi: async (d, v = !0) => {
    m.value.api = d, v && (await G(), await he());
  }, setRequestParams: j, resizeHeight: ne });
  return o({ ...B.value }), () => a.value.ssr ? c.value && oe() : oe();
} });
function xo() {
  const e = qt("MaProTableOptions"), { toolbars: t = [] } = e.value?.provider, n = (o) => t.find((a) => a.name === o);
  return { get: n, getAll: () => t, add: (o) => {
    t.find((a) => a.name === o.name) || t.push(o);
  }, remove: (o) => {
    const a = t.findIndex((r) => r.name === o);
    a !== -1 && t.splice(a, 1);
  }, hide: (o) => {
    n(o).show = !1;
  }, show: (o) => {
    n(o).show = !0;
  } };
}
const Zn = [{ name: "tag", render: (e, t, n) => Ft(kn, t, { default: () => e.row[t?.prop] }) }], Qn = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, eo = ke({ name: "IcOutlineRefresh" }, [["render", function(e, t, n, o, a, r) {
  return te(), xe("svg", Qn, [...t[0] || (t[0] = [de("path", { fill: "currentColor", d: "M17.65 6.35A7.96 7.96 0 0 0 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08A5.99 5.99 0 0 1 12 18c-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4z" }, null, -1)])]);
}]]), to = at({ __name: "proTableRefresh", props: { proxy: {} }, setup(e) {
  const t = async () => {
    await e.proxy.requestData();
  };
  return (n, o) => {
    const a = L("el-button");
    return te(), nt(a, { circle: "", onClick: t }, { default: Se(() => [g(eo)]), _: 1 });
  };
} }), no = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, oo = ke({ name: "IcRoundSearch" }, [["render", function(e, t, n, o, a, r) {
  return te(), xe("svg", no, [...t[0] || (t[0] = [de("path", { fill: "currentColor", d: "M15.5 14h-.79l-.28-.27a6.5 6.5 0 0 0 1.48-5.34c-.47-2.78-2.79-5-5.59-5.34a6.505 6.505 0 0 0-7.27 7.27c.34 2.8 2.56 5.12 5.34 5.59a6.5 6.5 0 0 0 5.34-1.48l.27.28v.79l4.25 4.25c.41.41 1.08.41 1.49 0c.41-.41.41-1.08 0-1.49zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5S14 7.01 14 9.5S11.99 14 9.5 14" }, null, -1)])]);
}]]), ao = at({ __name: "proTableSearch", props: { proxy: {} }, setup(e) {
  const t = async () => {
    e.proxy.getSearchRef().setShowState(!e.proxy.getSearchRef().getShowState()), document.querySelector(`.ma-pro-table-search${e.proxy.getCurrentId()}`).style.display = e.proxy.getSearchRef().getShowState() ? "block" : "none", await e.proxy.resizeHeight();
  };
  return (n, o) => {
    const a = L("el-button");
    return te(), nt(a, { circle: "", onClick: t }, { default: Se(() => [g(oo)]), _: 1 });
  };
} });
class ro {
  dom = null;
  options = { noPrint: void 0 };
  constructor(t, n = {}) {
    if (this.options = this.extend({ noPrint: ".no-print" }, n), typeof t == "string") try {
      this.dom = document.querySelector(t);
    } catch {
      this.dom = document.createElement("div"), this.dom.innerHTML = t;
    }
    else this.isDOM(t), this.dom = this.isDOM(t) ? t : t.$el;
    this.init();
  }
  init() {
    this.writeIframe(this.getStyle() + this.getHtml());
  }
  extend(t, n) {
    for (let o in n) t[o] = n[o];
    return t;
  }
  getStyle() {
    let t = "", n = document.querySelectorAll("style,link");
    for (let o = 0; o < n.length; o++) t += n[o].outerHTML;
    return t += "<style>" + (this.options?.noPrint ?? ".no-print") + "{ display: none; }</style>", t += "<style>html, body{ background-color: #fff; }</style>", t;
  }
  getHtml() {
    const t = document.querySelectorAll("input"), n = document.querySelectorAll("textarea"), o = document.querySelectorAll("select");
    for (let a = 0; a < t.length; a++) t[a].type === "checkbox" || t[a].type === "radio" ? t[a].checked === !0 ? t[a].setAttribute("checked", "checked") : t[a].removeAttribute("checked") : (t[a].type, t[a].setAttribute("value", t[a].value));
    for (let a = 0; a < n.length; a++) n[a].type === "textarea" && (n[a].innerHTML = n[a].value);
    for (let a = 0; a < o.length; a++) if (o[a].type === "select-one") {
      let r = o[a].children;
      for (let i in r) r[i].tagName === "OPTION" && (r[i]?.selected === !0 ? r[i].setAttribute("selected", "selected") : r[i].removeAttribute("selected"));
    }
    return this.dom.outerHTML;
  }
  writeIframe(t) {
    let n, o, a = document.createElement("iframe"), r = document.body.appendChild(a);
    a.id = "myIframe", a.setAttribute("style", "position:absolute; width:0; height:0; top:-10px; left:-10px;"), n = r.contentWindow ?? r.contentDocument, o = r.contentDocument ?? r.contentWindow.document, o.open(), o.write(t), o.close();
    const i = this;
    a.onload = () => {
      i.toPrint(n), setTimeout(() => {
        document.body.removeChild(a);
      }, 100);
    };
  }
  toPrint(t) {
    try {
      setTimeout(() => {
        t.focus();
        try {
          t.document.execCommand("print", !1, null) || t.print();
        } catch {
          t.print();
        }
        t.close();
      }, 10);
    } catch {
    }
  }
  isDOM(t) {
    return typeof HTMLElement == "object" ? t instanceof HTMLElement : t && typeof t == "object" && t.nodeType === 1 && typeof t.nodeName == "string";
  }
}
const io = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, lo = ke({ name: "IcOutlinePrint" }, [["render", function(e, t, n, o, a, r) {
  return te(), xe("svg", io, [...t[0] || (t[0] = [de("path", { fill: "currentColor", d: "M19 8h-1V3H6v5H5c-1.66 0-3 1.34-3 3v6h4v4h12v-4h4v-6c0-1.66-1.34-3-3-3M8 5h8v3H8zm8 12v2H8v-4h8zm2-2v-2H6v2H4v-4c0-.55.45-1 1-1h14c.55 0 1 .45 1 1v4z" }, null, -1), de("circle", { cx: "18", cy: "11.5", r: "1", fill: "currentColor" }, null, -1)])]);
}]]), so = at({ __name: "proTablePrint", props: { proxy: {} }, setup(e) {
  const t = () => {
    new ro(document.querySelector(`#ma-table${e.proxy.getCurrentId()}`));
  };
  return (n, o) => {
    const a = L("el-button");
    return te(), nt(a, { circle: "", onClick: t }, { default: Se(() => [g(lo)]), _: 1 });
  };
} }), co = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, uo = ke({ name: "IcOutlineSettings" }, [["render", function(e, t, n, o, a, r) {
  return te(), xe("svg", co, [...t[0] || (t[0] = [de("path", { fill: "currentColor", d: "M19.43 12.98c.04-.32.07-.64.07-.98c0-.34-.03-.66-.07-.98l2.11-1.65c.19-.15.24-.42.12-.64l-2-3.46a.5.5 0 0 0-.61-.22l-2.49 1c-.52-.4-1.08-.73-1.69-.98l-.38-2.65A.488.488 0 0 0 14 2h-4c-.25 0-.46.18-.49.42l-.38 2.65c-.61.25-1.17.59-1.69.98l-2.49-1a.566.566 0 0 0-.18-.03c-.17 0-.34.09-.43.25l-2 3.46c-.13.22-.07.49.12.64l2.11 1.65c-.04.32-.07.65-.07.98c0 .33.03.66.07.98l-2.11 1.65c-.19.15-.24.42-.12.64l2 3.46a.5.5 0 0 0 .61.22l2.49-1c.52.4 1.08.73 1.69.98l.38 2.65c.03.24.24.42.49.42h4c.25 0 .46-.18.49-.42l.38-2.65c.61-.25 1.17-.59 1.69-.98l2.49 1c.06.02.12.03.18.03c.17 0 .34-.09.43-.25l2-3.46c.12-.22.07-.49-.12-.64zm-1.98-1.71c.04.31.05.52.05.73c0 .21-.02.43-.05.73l-.14 1.13l.89.7l1.08.84l-.7 1.21l-1.27-.51l-1.04-.42l-.9.68c-.43.32-.84.56-1.25.73l-1.06.43l-.16 1.13l-.2 1.35h-1.4l-.19-1.35l-.16-1.13l-1.06-.43c-.43-.18-.83-.41-1.23-.71l-.91-.7l-1.06.43l-1.27.51l-.7-1.21l1.08-.84l.89-.7l-.14-1.13c-.03-.31-.05-.54-.05-.74s.02-.43.05-.73l.14-1.13l-.89-.7l-1.08-.84l.7-1.21l1.27.51l1.04.42l.9-.68c.43-.32.84-.56 1.25-.73l1.06-.43l.16-1.13l.2-1.35h1.39l.19 1.35l.16 1.13l1.06.43c.43.18.83.41 1.23.71l.91.7l1.06-.43l1.27-.51l.7 1.21l-1.07.85l-.89.7zM12 8c-2.21 0-4 1.79-4 4s1.79 4 4 4s4-1.79 4-4s-1.79-4-4-4m0 6c-1.1 0-2-.9-2-2s.9-2 2-2s2 .9 2 2s-.9 2-2 2" }, null, -1)])]);
}]]), ho = { xmlns: "http://www.w3.org/2000/svg", width: "1.5em", height: "1.5em", viewBox: "0 0 24 24" }, po = ke({ name: "IcRoundFirstPage" }, [["render", function(e, t, n, o, a, r) {
  return te(), xe("svg", ho, [...t[0] || (t[0] = [de("path", { fill: "currentColor", d: "M17.7 15.89L13.82 12l3.89-3.89A.996.996 0 1 0 16.3 6.7l-4.59 4.59a.996.996 0 0 0 0 1.41l4.59 4.59c.39.39 1.02.39 1.41 0a.993.993 0 0 0-.01-1.4M7 6c.55 0 1 .45 1 1v10c0 .55-.45 1-1 1s-1-.45-1-1V7c0-.55.45-1 1-1" }, null, -1)])]);
}]]), fo = { xmlns: "http://www.w3.org/2000/svg", width: "1.5em", height: "1.5em", viewBox: "0 0 24 24" }, mo = ke({ name: "IcRoundLastPage" }, [["render", function(e, t, n, o, a, r) {
  return te(), xe("svg", fo, [...t[0] || (t[0] = [de("path", { fill: "currentColor", d: "M6.29 8.11L10.18 12l-3.89 3.89A.996.996 0 1 0 7.7 17.3l4.59-4.59a.996.996 0 0 0 0-1.41L7.7 6.7a.996.996 0 0 0-1.41 0c-.38.39-.38 1.03 0 1.41M17 6c.55 0 1 .45 1 1v10c0 .55-.45 1-1 1s-1-.45-1-1V7c0-.55.45-1 1-1" }, null, -1)])]);
}]]), vo = { class: "mine-pro-table-col-setting" }, go = { class: "settings-list" }, bo = { class: "label" }, wo = { class: "setting-fixed" }, yo = at({ __name: "proTableSetting", props: { proxy: {} }, setup(e) {
  const t = ee();
  return jt(() => {
    He(() => {
      t.value = e.proxy.getTableColumns();
    });
  }), (n, o) => {
    const a = L("el-button"), r = L("el-switch"), i = L("el-link"), c = L("el-dropdown-item"), l = L("el-dropdown-menu"), p = L("el-dropdown");
    return te(), nt(p, { "max-height": 350, "hide-on-click": !1, trigger: "click" }, { dropdown: Se(() => [g(l, { class: Mn(`mine-cols-setting${n.proxy.getCurrentId()}`) }, { default: Se(() => [(te(!0), xe(Me, null, Nn(t.value, (s, f) => (te(), xe(Me, { key: f }, [s?.toolHide !== !0 ? (te(), nt(c, { key: 0 }, { default: Se(() => [de("div", vo, [de("div", go, [g(r, { modelValue: s.hide, "onUpdate:modelValue": (E) => s.hide = E, size: "small", "active-value": !1, "inactive-value": !0 }, null, 8, ["modelValue", "onUpdate:modelValue"]), de("div", bo, In(un(me)(s.label) ? s.label() : s.label ?? "unknown"), 1)]), de("div", wo, [g(i, { underline: "never", type: s?.fixed === "left" ? "primary" : void 0, onClick: () => s.fixed = s?.fixed !== "left" ? "left" : void 0 }, { default: Se(() => [g(po)]), _: 1 }, 8, ["type", "onClick"]), g(i, { underline: "never", type: s?.fixed === "right" ? "primary" : void 0, onClick: () => s.fixed = s?.fixed !== "right" ? "right" : void 0 }, { default: Se(() => [g(mo)]), _: 1 }, 8, ["type", "onClick"])])])]), _: 2 }, 1024)) : Rn("", !0)], 64))), 128))]), _: 1 }, 8, ["class"])]), default: Se(() => [g(a, { circle: "", style: { "margin-left": "12px" } }, { default: Se(() => [g(uo)]), _: 1 })]), _: 1 });
  };
} }), So = [{ name: "mineProTableRefresh", render: () => to, order: 1 }, { name: "mineProTableSearch", render: () => ao, order: 2 }, { name: "mineProTablePrint", render: () => so, order: 3 }, { name: "mineProTableSetting", render: () => yo, order: 4 }], Co = { install(e, t) {
  e.component(sn.name, sn);
  const n = ee(t ?? { ssr: !1, provider: { app: e } });
  n.value.provider.renderPlugins = Zn, n.value.provider.toolbars = So, e.provide("MaProTableOptions", n);
} };
export {
  Co as MaProTable,
  Co as default,
  Gn as useProTableRenderPlugin,
  xo as useProTableToolbar
};
