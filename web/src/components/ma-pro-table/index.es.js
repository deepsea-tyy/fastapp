var kn = Object.defineProperty;
var An = (t, e, n) => e in t ? kn(t, e, { enumerable: !0, configurable: !0, writable: !0, value: n }) : t[e] = n;
var Ae = (t, e, n) => An(t, typeof e != "symbol" ? e + "" : e, n);
import { onMounted as en, nextTick as Ut, getCurrentScope as Bn, onScopeDispose as Fn, getCurrentInstance as Tn, unref as En, isRef as Hn, inject as nn, createElementBlock as Ft, openBlock as ft, createElementVNode as St, defineComponent as fe, computed as ge, ref as ct, shallowRef as zn, watch as Ln, onBeforeUnmount as Xn, createVNode as y, Fragment as Gt, withDirectives as Yn, resolveComponent as V, vShow as jn, h as Ke, mergeProps as an, isVNode as qn, createBlock as he, withCtx as Nt, normalizeClass as $n, renderList as Wn, toDisplayString as Vn } from "vue";
import { ElTag as Gn } from "element-plus";
const xt = (t) => !!(t && t.constructor && t.call && t.apply), rn = (t, e, n = !1) => t ? t.slice().sort(n === !0 ? (o, a) => e(a) - e(o) : (o, a) => e(o) - e(a)) : [];
function Be(t) {
  return typeof t == "function" ? t() : En(t);
}
const Kn = typeof window < "u" && typeof document < "u";
function Un(t, e = !0, n) {
  Tn() ? en(t, n) : e ? t() : Ut(t);
}
const Jn = Kn ? window.document : void 0;
/**!
 * Sortable 1.15.2
 * @author	RubaXa   <trash@rubaxa.org>
 * @author	owenm    <owen23355@gmail.com>
 * @license MIT
 */
function ln(t, e) {
  var n = Object.keys(t);
  if (Object.getOwnPropertySymbols) {
    var o = Object.getOwnPropertySymbols(t);
    e && (o = o.filter(function(a) {
      return Object.getOwnPropertyDescriptor(t, a).enumerable;
    })), n.push.apply(n, o);
  }
  return n;
}
function Rt(t) {
  for (var e = 1; e < arguments.length; e++) {
    var n = arguments[e] != null ? arguments[e] : {};
    e % 2 ? ln(Object(n), !0).forEach(function(o) {
      Zn(t, o, n[o]);
    }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(t, Object.getOwnPropertyDescriptors(n)) : ln(Object(n)).forEach(function(o) {
      Object.defineProperty(t, o, Object.getOwnPropertyDescriptor(n, o));
    });
  }
  return t;
}
function Ue(t) {
  return Ue = typeof Symbol == "function" && typeof Symbol.iterator == "symbol" ? function(e) {
    return typeof e;
  } : function(e) {
    return e && typeof Symbol == "function" && e.constructor === Symbol && e !== Symbol.prototype ? "symbol" : typeof e;
  }, Ue(t);
}
function Zn(t, e, n) {
  return e in t ? Object.defineProperty(t, e, { value: n, enumerable: !0, configurable: !0, writable: !0 }) : t[e] = n, t;
}
function At() {
  return At = Object.assign || function(t) {
    for (var e = 1; e < arguments.length; e++) {
      var n = arguments[e];
      for (var o in n) Object.prototype.hasOwnProperty.call(n, o) && (t[o] = n[o]);
    }
    return t;
  }, At.apply(this, arguments);
}
function Qn(t, e) {
  if (t == null) return {};
  var n, o, a = function(i, c) {
    if (i == null) return {};
    var u, v, s = {}, g = Object.keys(i);
    for (v = 0; v < g.length; v++) u = g[v], c.indexOf(u) >= 0 || (s[u] = i[u]);
    return s;
  }(t, e);
  if (Object.getOwnPropertySymbols) {
    var r = Object.getOwnPropertySymbols(t);
    for (o = 0; o < r.length; o++) n = r[o], e.indexOf(n) >= 0 || Object.prototype.propertyIsEnumerable.call(t, n) && (a[n] = t[n]);
  }
  return a;
}
function Bt(t) {
  if (typeof window < "u" && window.navigator) return !!navigator.userAgent.match(t);
}
var Ht = Bt(/(?:Trident.*rv[ :]?11\.|msie|iemobile|Windows Phone)/i), ve = Bt(/Edge/i), sn = Bt(/firefox/i), ce = Bt(/safari/i) && !Bt(/chrome/i) && !Bt(/android/i), xn = Bt(/iP(ad|od|hone)/i), _n = Bt(/chrome/i) && Bt(/android/i), Dn = { capture: !1, passive: !1 };
function F(t, e, n) {
  t.addEventListener(e, n, !Ht && Dn);
}
function N(t, e, n) {
  t.removeEventListener(e, n, !Ht && Dn);
}
function Oe(t, e) {
  if (e) {
    if (e[0] === ">" && (e = e.substring(1)), t) try {
      if (t.matches) return t.matches(e);
      if (t.msMatchesSelector) return t.msMatchesSelector(e);
      if (t.webkitMatchesSelector) return t.webkitMatchesSelector(e);
    } catch {
      return !1;
    }
    return !1;
  }
}
function to(t) {
  return t.host && t !== document && t.host.nodeType ? t.host : t.parentNode;
}
function Ot(t, e, n, o) {
  if (t) {
    n = n || document;
    do {
      if (e != null && (e[0] === ">" ? t.parentNode === n && Oe(t, e) : Oe(t, e)) || o && t === n) return t;
      if (t === n) break;
    } while (t = to(t));
  }
  return null;
}
var ue, cn = /\s+/g;
function bt(t, e, n) {
  if (t && e) if (t.classList) t.classList[n ? "add" : "remove"](e);
  else {
    var o = (" " + t.className + " ").replace(cn, " ").replace(" " + e + " ", " ");
    t.className = (o + (n ? " " + e : "")).replace(cn, " ");
  }
}
function T(t, e, n) {
  var o = t && t.style;
  if (o) {
    if (n === void 0) return document.defaultView && document.defaultView.getComputedStyle ? n = document.defaultView.getComputedStyle(t, "") : t.currentStyle && (n = t.currentStyle), e === void 0 ? n : n[e];
    e in o || e.indexOf("webkit") !== -1 || (e = "-webkit-" + e), o[e] = n + (typeof n == "string" ? "" : "px");
  }
}
function ne(t, e) {
  var n = "";
  if (typeof t == "string") n = t;
  else do {
    var o = T(t, "transform");
    o && o !== "none" && (n = o + " " + n);
  } while (!e && (t = t.parentNode));
  var a = window.DOMMatrix || window.WebKitCSSMatrix || window.CSSMatrix || window.MSCSSMatrix;
  return a && new a(n);
}
function un(t, e, n) {
  if (t) {
    var o = t.getElementsByTagName(e), a = 0, r = o.length;
    if (n) for (; a < r; a++) n(o[a], a);
    return o;
  }
  return [];
}
function It() {
  var t = document.scrollingElement;
  return t || document.documentElement;
}
function K(t, e, n, o, a) {
  if (t.getBoundingClientRect || t === window) {
    var r, i, c, u, v, s, g;
    if (t !== window && t.parentNode && t !== It() ? (i = (r = t.getBoundingClientRect()).top, c = r.left, u = r.bottom, v = r.right, s = r.height, g = r.width) : (i = 0, c = 0, u = window.innerHeight, v = window.innerWidth, s = window.innerHeight, g = window.innerWidth), (e || n) && t !== window && (a = a || t.parentNode, !Ht)) do
      if (a && a.getBoundingClientRect && (T(a, "transform") !== "none" || n && T(a, "position") !== "static")) {
        var C = a.getBoundingClientRect();
        i -= C.top + parseInt(T(a, "border-top-width")), c -= C.left + parseInt(T(a, "border-left-width")), u = i + r.height, v = c + r.width;
        break;
      }
    while (a = a.parentNode);
    if (o && t !== window) {
      var b = ne(a || t), X = b && b.a, R = b && b.d;
      b && (u = (i /= R) + (s /= R), v = (c /= X) + (g /= X));
    }
    return { top: i, left: c, bottom: u, right: v, width: g, height: s };
  }
}
function dn(t, e, n) {
  for (var o = qt(t, !0), a = K(t)[e]; o; ) {
    if (!(a >= K(o)[n])) return o;
    if (o === It()) break;
    o = qt(o, !1);
  }
  return !1;
}
function oe(t, e, n, o) {
  for (var a = 0, r = 0, i = t.children; r < i.length; ) {
    if (i[r].style.display !== "none" && i[r] !== S.ghost && (o || i[r] !== S.dragged) && Ot(i[r], n.draggable, t, !1)) {
      if (a === e) return i[r];
      a++;
    }
    r++;
  }
  return null;
}
function Je(t, e) {
  for (var n = t.lastElementChild; n && (n === S.ghost || T(n, "display") === "none" || e && !Oe(n, e)); ) n = n.previousElementSibling;
  return n || null;
}
function Et(t, e) {
  var n = 0;
  if (!t || !t.parentNode) return -1;
  for (; t = t.previousElementSibling; ) t.nodeName.toUpperCase() === "TEMPLATE" || t === S.clone || e && !Oe(t, e) || n++;
  return n;
}
function hn(t) {
  var e = 0, n = 0, o = It();
  if (t) do {
    var a = ne(t), r = a.a, i = a.d;
    e += t.scrollLeft * r, n += t.scrollTop * i;
  } while (t !== o && (t = t.parentNode));
  return [e, n];
}
function qt(t, e) {
  if (!t || !t.getBoundingClientRect) return It();
  var n = t, o = !1;
  do
    if (n.clientWidth < n.scrollWidth || n.clientHeight < n.scrollHeight) {
      var a = T(n);
      if (n.clientWidth < n.scrollWidth && (a.overflowX == "auto" || a.overflowX == "scroll") || n.clientHeight < n.scrollHeight && (a.overflowY == "auto" || a.overflowY == "scroll")) {
        if (!n.getBoundingClientRect || n === document.body) return It();
        if (o || e) return n;
        o = !0;
      }
    }
  while (n = n.parentNode);
  return It();
}
function Fe(t, e) {
  return Math.round(t.top) === Math.round(e.top) && Math.round(t.left) === Math.round(e.left) && Math.round(t.height) === Math.round(e.height) && Math.round(t.width) === Math.round(e.width);
}
function Cn(t, e) {
  return function() {
    if (!ue) {
      var n = arguments;
      n.length === 1 ? t.call(this, n[0]) : t.apply(this, n), ue = setTimeout(function() {
        ue = void 0;
      }, e);
    }
  };
}
function On(t, e, n) {
  t.scrollLeft += e, t.scrollTop += n;
}
function pn(t) {
  var e = window.Polymer, n = window.jQuery || window.Zepto;
  return e && e.dom ? e.dom(t).cloneNode(!0) : n ? n(t).clone(!0)[0] : t.cloneNode(!0);
}
function fn(t, e, n) {
  var o = {};
  return Array.from(t.children).forEach(function(a) {
    var r, i, c, u;
    if (Ot(a, e.draggable, t, !1) && !a.animated && a !== n) {
      var v = K(a);
      o.left = Math.min((r = o.left) !== null && r !== void 0 ? r : 1 / 0, v.left), o.top = Math.min((i = o.top) !== null && i !== void 0 ? i : 1 / 0, v.top), o.right = Math.max((c = o.right) !== null && c !== void 0 ? c : -1 / 0, v.right), o.bottom = Math.max((u = o.bottom) !== null && u !== void 0 ? u : -1 / 0, v.bottom);
    }
  }), o.width = o.right - o.left, o.height = o.bottom - o.top, o.x = o.left, o.y = o.top, o;
}
var yt = "Sortable" + (/* @__PURE__ */ new Date()).getTime();
function eo() {
  var t, e = [];
  return { captureAnimationState: function() {
    e = [], this.options.animation && [].slice.call(this.el.children).forEach(function(n) {
      if (T(n, "display") !== "none" && n !== S.ghost) {
        e.push({ target: n, rect: K(n) });
        var o = Rt({}, e[e.length - 1].rect);
        if (n.thisAnimationDuration) {
          var a = ne(n, !0);
          a && (o.top -= a.f, o.left -= a.e);
        }
        n.fromRect = o;
      }
    });
  }, addAnimationState: function(n) {
    e.push(n);
  }, removeAnimationState: function(n) {
    e.splice(function(o, a) {
      for (var r in o) if (o.hasOwnProperty(r)) {
        for (var i in a) if (a.hasOwnProperty(i) && a[i] === o[r][i]) return Number(r);
      }
      return -1;
    }(e, { target: n }), 1);
  }, animateAll: function(n) {
    var o = this;
    if (!this.options.animation) return clearTimeout(t), void (typeof n == "function" && n());
    var a = !1, r = 0;
    e.forEach(function(i) {
      var c = 0, u = i.target, v = u.fromRect, s = K(u), g = u.prevFromRect, C = u.prevToRect, b = i.rect, X = ne(u, !0);
      X && (s.top -= X.f, s.left -= X.e), u.toRect = s, u.thisAnimationDuration && Fe(g, s) && !Fe(v, s) && (b.top - s.top) / (b.left - s.left) == (v.top - s.top) / (v.left - s.left) && (c = function(R, P, Z, vt) {
        return Math.sqrt(Math.pow(P.top - R.top, 2) + Math.pow(P.left - R.left, 2)) / Math.sqrt(Math.pow(P.top - Z.top, 2) + Math.pow(P.left - Z.left, 2)) * vt.animation;
      }(b, g, C, o.options)), Fe(s, v) || (u.prevFromRect = v, u.prevToRect = s, c || (c = o.options.animation), o.animate(u, b, s, c)), c && (a = !0, r = Math.max(r, c), clearTimeout(u.animationResetTimer), u.animationResetTimer = setTimeout(function() {
        u.animationTime = 0, u.prevFromRect = null, u.fromRect = null, u.prevToRect = null, u.thisAnimationDuration = null;
      }, c), u.thisAnimationDuration = c);
    }), clearTimeout(t), a ? t = setTimeout(function() {
      typeof n == "function" && n();
    }, r) : typeof n == "function" && n(), e = [];
  }, animate: function(n, o, a, r) {
    if (r) {
      T(n, "transition", ""), T(n, "transform", "");
      var i = ne(this.el), c = i && i.a, u = i && i.d, v = (o.left - a.left) / (c || 1), s = (o.top - a.top) / (u || 1);
      n.animatingX = !!v, n.animatingY = !!s, T(n, "transform", "translate3d(" + v + "px," + s + "px,0)"), this.forRepaintDummy = function(g) {
        return g.offsetWidth;
      }(n), T(n, "transition", "transform " + r + "ms" + (this.options.easing ? " " + this.options.easing : "")), T(n, "transform", "translate3d(0,0,0)"), typeof n.animated == "number" && clearTimeout(n.animated), n.animated = setTimeout(function() {
        T(n, "transition", ""), T(n, "transform", ""), n.animated = !1, n.animatingX = !1, n.animatingY = !1;
      }, r);
    }
  } };
}
var Zt = [], He = { initializeByDefault: !0 }, pe = { mount: function(t) {
  for (var e in He) He.hasOwnProperty(e) && !(e in t) && (t[e] = He[e]);
  Zt.forEach(function(n) {
    if (n.pluginName === t.pluginName) throw "Sortable: Cannot mount plugin ".concat(t.pluginName, " more than once");
  }), Zt.push(t);
}, pluginEvent: function(t, e, n) {
  var o = this;
  this.eventCanceled = !1, n.cancel = function() {
    o.eventCanceled = !0;
  };
  var a = t + "Global";
  Zt.forEach(function(r) {
    e[r.pluginName] && (e[r.pluginName][a] && e[r.pluginName][a](Rt({ sortable: e }, n)), e.options[r.pluginName] && e[r.pluginName][t] && e[r.pluginName][t](Rt({ sortable: e }, n)));
  });
}, initializePlugins: function(t, e, n, o) {
  for (var a in Zt.forEach(function(i) {
    var c = i.pluginName;
    if (t.options[c] || i.initializeByDefault) {
      var u = new i(t, e, t.options);
      u.sortable = t, u.options = t.options, t[c] = u, At(n, u.defaults);
    }
  }), t.options) if (t.options.hasOwnProperty(a)) {
    var r = this.modifyOption(t, a, t.options[a]);
    r !== void 0 && (t.options[a] = r);
  }
}, getEventProperties: function(t, e) {
  var n = {};
  return Zt.forEach(function(o) {
    typeof o.eventProperties == "function" && At(n, o.eventProperties.call(e[o.pluginName], t));
  }), n;
}, modifyOption: function(t, e, n) {
  var o;
  return Zt.forEach(function(a) {
    t[a.pluginName] && a.optionListeners && typeof a.optionListeners[e] == "function" && (o = a.optionListeners[e].call(t[a.pluginName], n));
  }), o;
} }, no = ["evt"], pt = function(t, e) {
  var n = arguments.length > 2 && arguments[2] !== void 0 ? arguments[2] : {}, o = n.evt, a = Qn(n, no);
  pe.pluginEvent.bind(S)(t, e, Rt({ dragEl: f, parentEl: q, ghostEl: x, rootEl: Y, nextEl: Kt, lastDownEl: De, cloneEl: $, cloneHidden: jt, dragStarted: ie, putSortable: tt, activeSortable: S.active, originalEvent: o, oldIndex: ee, oldDraggableIndex: de, newIndex: wt, newDraggableIndex: Yt, hideGhostForTarget: Rn, unhideGhostForTarget: In, cloneNowHidden: function() {
    jt = !0;
  }, cloneNowShown: function() {
    jt = !1;
  }, dispatchSortableEvent: function(r) {
    st({ sortable: e, name: r, originalEvent: o });
  } }, a));
};
function st(t) {
  (function(e) {
    var n = e.sortable, o = e.rootEl, a = e.name, r = e.targetEl, i = e.cloneEl, c = e.toEl, u = e.fromEl, v = e.oldIndex, s = e.newIndex, g = e.oldDraggableIndex, C = e.newDraggableIndex, b = e.originalEvent, X = e.putSortable, R = e.extraEventProperties;
    if (n = n || o && o[yt]) {
      var P, Z = n.options, vt = "on" + a.charAt(0).toUpperCase() + a.substr(1);
      !window.CustomEvent || Ht || ve ? (P = document.createEvent("Event")).initEvent(a, !0, !0) : P = new CustomEvent(a, { bubbles: !0, cancelable: !0 }), P.to = c || o, P.from = u || o, P.item = r || o, P.clone = i, P.oldIndex = v, P.newIndex = s, P.oldDraggableIndex = g, P.newDraggableIndex = C, P.originalEvent = b, P.pullMode = X ? X.lastPutMode : void 0;
      var et = Rt(Rt({}, R), pe.getEventProperties(a, n));
      for (var at in et) P[at] = et[at];
      o && o.dispatchEvent(P), Z[vt] && Z[vt].call(n, P);
    }
  })(Rt({ putSortable: tt, cloneEl: $, targetEl: f, rootEl: Y, oldIndex: ee, oldDraggableIndex: de, newIndex: wt, newDraggableIndex: Yt }, t));
}
var f, q, x, Y, Kt, De, $, jt, ee, wt, de, Yt, be, tt, Wt, Ct, ze, Le, vn, mn, ie, Qt, ae, we, ot, te = !1, Pe = !1, Me = [], re = !1, ye = !1, Xe = [], Ze = !1, Se = [], Re = typeof document < "u", Te = xn, gn = ve || Ht ? "cssFloat" : "float", oo = Re && !_n && !xn && "draggable" in document.createElement("div"), Pn = function() {
  if (Re) {
    if (Ht) return !1;
    var t = document.createElement("x");
    return t.style.cssText = "pointer-events:auto", t.style.pointerEvents === "auto";
  }
}(), Mn = function(t, e) {
  var n = T(t), o = parseInt(n.width) - parseInt(n.paddingLeft) - parseInt(n.paddingRight) - parseInt(n.borderLeftWidth) - parseInt(n.borderRightWidth), a = oe(t, 0, e), r = oe(t, 1, e), i = a && T(a), c = r && T(r), u = i && parseInt(i.marginLeft) + parseInt(i.marginRight) + K(a).width, v = c && parseInt(c.marginLeft) + parseInt(c.marginRight) + K(r).width;
  if (n.display === "flex") return n.flexDirection === "column" || n.flexDirection === "column-reverse" ? "vertical" : "horizontal";
  if (n.display === "grid") return n.gridTemplateColumns.split(" ").length <= 1 ? "vertical" : "horizontal";
  if (a && i.float && i.float !== "none") {
    var s = i.float === "left" ? "left" : "right";
    return !r || c.clear !== "both" && c.clear !== s ? "horizontal" : "vertical";
  }
  return a && (i.display === "block" || i.display === "flex" || i.display === "table" || i.display === "grid" || u >= o && n[gn] === "none" || r && n[gn] === "none" && u + v > o) ? "vertical" : "horizontal";
}, Nn = function(t) {
  function e(a, r) {
    return function(i, c, u, v) {
      var s = i.options.group.name && c.options.group.name && i.options.group.name === c.options.group.name;
      if (a == null && (r || s)) return !0;
      if (a == null || a === !1) return !1;
      if (r && a === "clone") return a;
      if (typeof a == "function") return e(a(i, c, u, v), r)(i, c, u, v);
      var g = (r ? i : c).options.group.name;
      return a === !0 || typeof a == "string" && a === g || a.join && a.indexOf(g) > -1;
    };
  }
  var n = {}, o = t.group;
  o && Ue(o) == "object" || (o = { name: o }), n.name = o.name, n.checkPull = e(o.pull, !0), n.checkPut = e(o.put), n.revertClone = o.revertClone, t.group = n;
}, Rn = function() {
  !Pn && x && T(x, "display", "none");
}, In = function() {
  !Pn && x && T(x, "display", "");
};
Re && !_n && document.addEventListener("click", function(t) {
  if (Pe) return t.preventDefault(), t.stopPropagation && t.stopPropagation(), t.stopImmediatePropagation && t.stopImmediatePropagation(), Pe = !1, !1;
}, !0);
var Vt = function(t) {
  if (f) {
    t = t.touches ? t.touches[0] : t;
    var e = (a = t.clientX, r = t.clientY, Me.some(function(c) {
      var u = c[yt].options.emptyInsertThreshold;
      if (u && !Je(c)) {
        var v = K(c), s = a >= v.left - u && a <= v.right + u, g = r >= v.top - u && r <= v.bottom + u;
        return s && g ? i = c : void 0;
      }
    }), i);
    if (e) {
      var n = {};
      for (var o in t) t.hasOwnProperty(o) && (n[o] = t[o]);
      n.target = n.rootEl = e, n.preventDefault = void 0, n.stopPropagation = void 0, e[yt]._onDragOver(n);
    }
  }
  var a, r, i;
}, ao = function(t) {
  f && f.parentNode[yt]._isOutsideThisEl(t.target);
};
function S(t, e) {
  if (!t || !t.nodeType || t.nodeType !== 1) throw "Sortable: `el` must be an HTMLElement, not ".concat({}.toString.call(t));
  this.el = t, this.options = e = At({}, e), t[yt] = this;
  var n = { group: null, sort: !0, disabled: !1, store: null, handle: null, draggable: /^[uo]l$/i.test(t.nodeName) ? ">li" : ">*", swapThreshold: 1, invertSwap: !1, invertedSwapThreshold: null, removeCloneOnHide: !0, direction: function() {
    return Mn(t, this.options);
  }, ghostClass: "sortable-ghost", chosenClass: "sortable-chosen", dragClass: "sortable-drag", ignore: "a, img", filter: null, preventOnFilter: !0, animation: 0, easing: null, setData: function(r, i) {
    r.setData("Text", i.textContent);
  }, dropBubble: !1, dragoverBubble: !1, dataIdAttr: "data-id", delay: 0, delayOnTouchOnly: !1, touchStartThreshold: (Number.parseInt ? Number : window).parseInt(window.devicePixelRatio, 10) || 1, forceFallback: !1, fallbackClass: "sortable-fallback", fallbackOnBody: !1, fallbackTolerance: 0, fallbackOffset: { x: 0, y: 0 }, supportPointer: S.supportPointer !== !1 && "PointerEvent" in window && !ce, emptyInsertThreshold: 5 };
  for (var o in pe.initializePlugins(this, t, n), n) !(o in e) && (e[o] = n[o]);
  for (var a in Nn(e), this) a.charAt(0) === "_" && typeof this[a] == "function" && (this[a] = this[a].bind(this));
  this.nativeDraggable = !e.forceFallback && oo, this.nativeDraggable && (this.options.touchStartThreshold = 1), e.supportPointer ? F(t, "pointerdown", this._onTapStart) : (F(t, "mousedown", this._onTapStart), F(t, "touchstart", this._onTapStart)), this.nativeDraggable && (F(t, "dragover", this), F(t, "dragenter", this)), Me.push(this.el), e.store && e.store.get && this.sort(e.store.get(this) || []), At(this, eo());
}
function Ee(t, e, n, o, a, r, i, c) {
  var u, v, s = t[yt], g = s.options.onMove;
  return !window.CustomEvent || Ht || ve ? (u = document.createEvent("Event")).initEvent("move", !0, !0) : u = new CustomEvent("move", { bubbles: !0, cancelable: !0 }), u.to = e, u.from = t, u.dragged = n, u.draggedRect = o, u.related = a || e, u.relatedRect = r || K(e), u.willInsertAfter = c, u.originalEvent = i, t.dispatchEvent(u), g && (v = g.call(s, u, i)), v;
}
function Ye(t) {
  t.draggable = !1;
}
function ro() {
  Ze = !1;
}
function io(t) {
  for (var e = t.tagName + t.className + t.src + t.href + t.textContent, n = e.length, o = 0; n--; ) o += e.charCodeAt(n);
  return o.toString(36);
}
function xe(t) {
  return setTimeout(t, 0);
}
function je(t) {
  return clearTimeout(t);
}
S.prototype = { constructor: S, _isOutsideThisEl: function(t) {
  this.el.contains(t) || t === this.el || (Qt = null);
}, _getDirection: function(t, e) {
  return typeof this.options.direction == "function" ? this.options.direction.call(this, t, e, f) : this.options.direction;
}, _onTapStart: function(t) {
  if (t.cancelable) {
    var e = this, n = this.el, o = this.options, a = o.preventOnFilter, r = t.type, i = t.touches && t.touches[0] || t.pointerType && t.pointerType === "touch" && t, c = (i || t).target, u = t.target.shadowRoot && (t.path && t.path[0] || t.composedPath && t.composedPath()[0]) || c, v = o.filter;
    if (function(s) {
      Se.length = 0;
      for (var g = s.getElementsByTagName("input"), C = g.length; C--; ) {
        var b = g[C];
        b.checked && Se.push(b);
      }
    }(n), !f && !(/mousedown|pointerdown/.test(r) && t.button !== 0 || o.disabled) && !u.isContentEditable && (this.nativeDraggable || !ce || !c || c.tagName.toUpperCase() !== "SELECT") && !((c = Ot(c, o.draggable, n, !1)) && c.animated || De === c)) {
      if (ee = Et(c), de = Et(c, o.draggable), typeof v == "function") {
        if (v.call(this, t, c, this)) return st({ sortable: e, rootEl: u, name: "filter", targetEl: c, toEl: n, fromEl: n }), pt("filter", e, { evt: t }), void (a && t.cancelable && t.preventDefault());
      } else if (v && (v = v.split(",").some(function(s) {
        if (s = Ot(u, s.trim(), n, !1)) return st({ sortable: e, rootEl: s, name: "filter", targetEl: c, fromEl: n, toEl: n }), pt("filter", e, { evt: t }), !0;
      }))) return void (a && t.cancelable && t.preventDefault());
      o.handle && !Ot(u, o.handle, n, !1) || this._prepareDragStart(t, i, c);
    }
  }
}, _prepareDragStart: function(t, e, n) {
  var o, a = this, r = a.el, i = a.options, c = r.ownerDocument;
  if (n && !f && n.parentNode === r) {
    var u = K(n);
    if (Y = r, q = (f = n).parentNode, Kt = f.nextSibling, De = n, be = i.group, S.dragged = f, Wt = { target: f, clientX: (e || t).clientX, clientY: (e || t).clientY }, vn = Wt.clientX - u.left, mn = Wt.clientY - u.top, this._lastX = (e || t).clientX, this._lastY = (e || t).clientY, f.style["will-change"] = "all", o = function() {
      pt("delayEnded", a, { evt: t }), S.eventCanceled ? a._onDrop() : (a._disableDelayedDragEvents(), !sn && a.nativeDraggable && (f.draggable = !0), a._triggerDragStart(t, e), st({ sortable: a, name: "choose", originalEvent: t }), bt(f, i.chosenClass, !0));
    }, i.ignore.split(",").forEach(function(v) {
      un(f, v.trim(), Ye);
    }), F(c, "dragover", Vt), F(c, "mousemove", Vt), F(c, "touchmove", Vt), F(c, "mouseup", a._onDrop), F(c, "touchend", a._onDrop), F(c, "touchcancel", a._onDrop), sn && this.nativeDraggable && (this.options.touchStartThreshold = 4, f.draggable = !0), pt("delayStart", this, { evt: t }), !i.delay || i.delayOnTouchOnly && !e || this.nativeDraggable && (ve || Ht)) o();
    else {
      if (S.eventCanceled) return void this._onDrop();
      F(c, "mouseup", a._disableDelayedDrag), F(c, "touchend", a._disableDelayedDrag), F(c, "touchcancel", a._disableDelayedDrag), F(c, "mousemove", a._delayedDragTouchMoveHandler), F(c, "touchmove", a._delayedDragTouchMoveHandler), i.supportPointer && F(c, "pointermove", a._delayedDragTouchMoveHandler), a._dragStartTimer = setTimeout(o, i.delay);
    }
  }
}, _delayedDragTouchMoveHandler: function(t) {
  var e = t.touches ? t.touches[0] : t;
  Math.max(Math.abs(e.clientX - this._lastX), Math.abs(e.clientY - this._lastY)) >= Math.floor(this.options.touchStartThreshold / (this.nativeDraggable && window.devicePixelRatio || 1)) && this._disableDelayedDrag();
}, _disableDelayedDrag: function() {
  f && Ye(f), clearTimeout(this._dragStartTimer), this._disableDelayedDragEvents();
}, _disableDelayedDragEvents: function() {
  var t = this.el.ownerDocument;
  N(t, "mouseup", this._disableDelayedDrag), N(t, "touchend", this._disableDelayedDrag), N(t, "touchcancel", this._disableDelayedDrag), N(t, "mousemove", this._delayedDragTouchMoveHandler), N(t, "touchmove", this._delayedDragTouchMoveHandler), N(t, "pointermove", this._delayedDragTouchMoveHandler);
}, _triggerDragStart: function(t, e) {
  e = e || t.pointerType == "touch" && t, !this.nativeDraggable || e ? this.options.supportPointer ? F(document, "pointermove", this._onTouchMove) : F(document, e ? "touchmove" : "mousemove", this._onTouchMove) : (F(f, "dragend", this), F(Y, "dragstart", this._onDragStart));
  try {
    document.selection ? xe(function() {
      document.selection.empty();
    }) : window.getSelection().removeAllRanges();
  } catch {
  }
}, _dragStarted: function(t, e) {
  if (te = !1, Y && f) {
    pt("dragStarted", this, { evt: e }), this.nativeDraggable && F(document, "dragover", ao);
    var n = this.options;
    !t && bt(f, n.dragClass, !1), bt(f, n.ghostClass, !0), S.active = this, t && this._appendGhost(), st({ sortable: this, name: "start", originalEvent: e });
  } else this._nulling();
}, _emulateDragOver: function() {
  if (Ct) {
    this._lastX = Ct.clientX, this._lastY = Ct.clientY, Rn();
    for (var t = document.elementFromPoint(Ct.clientX, Ct.clientY), e = t; t && t.shadowRoot && (t = t.shadowRoot.elementFromPoint(Ct.clientX, Ct.clientY)) !== e; ) e = t;
    if (f.parentNode[yt]._isOutsideThisEl(t), e) do {
      if (e[yt] && e[yt]._onDragOver({ clientX: Ct.clientX, clientY: Ct.clientY, target: t, rootEl: e }) && !this.options.dragoverBubble)
        break;
      t = e;
    } while (e = e.parentNode);
    In();
  }
}, _onTouchMove: function(t) {
  if (Wt) {
    var e = this.options, n = e.fallbackTolerance, o = e.fallbackOffset, a = t.touches ? t.touches[0] : t, r = x && ne(x, !0), i = x && r && r.a, c = x && r && r.d, u = Te && ot && hn(ot), v = (a.clientX - Wt.clientX + o.x) / (i || 1) + (u ? u[0] - Xe[0] : 0) / (i || 1), s = (a.clientY - Wt.clientY + o.y) / (c || 1) + (u ? u[1] - Xe[1] : 0) / (c || 1);
    if (!S.active && !te) {
      if (n && Math.max(Math.abs(a.clientX - this._lastX), Math.abs(a.clientY - this._lastY)) < n) return;
      this._onDragStart(t, !0);
    }
    if (x) {
      r ? (r.e += v - (ze || 0), r.f += s - (Le || 0)) : r = { a: 1, b: 0, c: 0, d: 1, e: v, f: s };
      var g = "matrix(".concat(r.a, ",").concat(r.b, ",").concat(r.c, ",").concat(r.d, ",").concat(r.e, ",").concat(r.f, ")");
      T(x, "webkitTransform", g), T(x, "mozTransform", g), T(x, "msTransform", g), T(x, "transform", g), ze = v, Le = s, Ct = a;
    }
    t.cancelable && t.preventDefault();
  }
}, _appendGhost: function() {
  if (!x) {
    var t = this.options.fallbackOnBody ? document.body : Y, e = K(f, !0, Te, !0, t), n = this.options;
    if (Te) {
      for (ot = t; T(ot, "position") === "static" && T(ot, "transform") === "none" && ot !== document; ) ot = ot.parentNode;
      ot !== document.body && ot !== document.documentElement ? (ot === document && (ot = It()), e.top += ot.scrollTop, e.left += ot.scrollLeft) : ot = It(), Xe = hn(ot);
    }
    bt(x = f.cloneNode(!0), n.ghostClass, !1), bt(x, n.fallbackClass, !0), bt(x, n.dragClass, !0), T(x, "transition", ""), T(x, "transform", ""), T(x, "box-sizing", "border-box"), T(x, "margin", 0), T(x, "top", e.top), T(x, "left", e.left), T(x, "width", e.width), T(x, "height", e.height), T(x, "opacity", "0.8"), T(x, "position", Te ? "absolute" : "fixed"), T(x, "zIndex", "100000"), T(x, "pointerEvents", "none"), S.ghost = x, t.appendChild(x), T(x, "transform-origin", vn / parseInt(x.style.width) * 100 + "% " + mn / parseInt(x.style.height) * 100 + "%");
  }
}, _onDragStart: function(t, e) {
  var n = this, o = t.dataTransfer, a = n.options;
  pt("dragStart", this, { evt: t }), S.eventCanceled ? this._onDrop() : (pt("setupClone", this), S.eventCanceled || (($ = pn(f)).removeAttribute("id"), $.draggable = !1, $.style["will-change"] = "", this._hideClone(), bt($, this.options.chosenClass, !1), S.clone = $), n.cloneId = xe(function() {
    pt("clone", n), S.eventCanceled || (n.options.removeCloneOnHide || Y.insertBefore($, f), n._hideClone(), st({ sortable: n, name: "clone" }));
  }), !e && bt(f, a.dragClass, !0), e ? (Pe = !0, n._loopId = setInterval(n._emulateDragOver, 50)) : (N(document, "mouseup", n._onDrop), N(document, "touchend", n._onDrop), N(document, "touchcancel", n._onDrop), o && (o.effectAllowed = "move", a.setData && a.setData.call(n, o, f)), F(document, "drop", n), T(f, "transform", "translateZ(0)")), te = !0, n._dragStartId = xe(n._dragStarted.bind(n, e, t)), F(document, "selectstart", n), ie = !0, ce && T(document.body, "user-select", "none"));
}, _onDragOver: function(t) {
  var e, n, o, a, r = this.el, i = t.target, c = this.options, u = c.group, v = S.active, s = be === u, g = c.sort, C = tt || v, b = this, X = !1;
  if (!Ze) {
    if (t.preventDefault !== void 0 && t.cancelable && t.preventDefault(), i = Ot(i, c.draggable, r, !0), gt("dragOver"), S.eventCanceled) return X;
    if (f.contains(t.target) || i.animated && i.animatingX && i.animatingY || b._ignoreWhileAnimating === i) return it(!1);
    if (Pe = !1, v && !c.disabled && (s ? g || (o = q !== Y) : tt === this || (this.lastPutMode = be.checkPull(this, v, f, t)) && u.checkPut(this, v, f, t))) {
      if (a = this._getDirection(t, i) === "vertical", e = K(f), gt("dragOverValid"), S.eventCanceled) return X;
      if (o) return q = Y, _t(), this._hideClone(), gt("revert"), S.eventCanceled || (Kt ? Y.insertBefore(f, Kt) : Y.appendChild(f)), it(!0);
      var R = Je(r, c.draggable);
      if (!R || function(k, Q, H) {
        var W = K(Je(H.el, H.options.draggable)), dt = fn(H.el, H.options, x), j = 10;
        return Q ? k.clientX > dt.right + j || k.clientY > W.bottom && k.clientX > W.left : k.clientY > dt.bottom + j || k.clientX > W.right && k.clientY > W.top;
      }(t, a, this) && !R.animated) {
        if (R === f) return it(!1);
        if (R && r === t.target && (i = R), i && (n = K(i)), Ee(Y, r, f, e, i, n, t, !!i) !== !1) return _t(), R && R.nextSibling ? r.insertBefore(f, R.nextSibling) : r.appendChild(f), q = r, Pt(), it(!0);
      } else if (R && function(k, Q, H) {
        var W = K(oe(H.el, 0, H.options, !0)), dt = fn(H.el, H.options, x), j = 10;
        return Q ? k.clientX < dt.left - j || k.clientY < W.top && k.clientX < W.right : k.clientY < dt.top - j || k.clientY < W.bottom && k.clientX < W.left;
      }(t, a, this)) {
        var P = oe(r, 0, c, !0);
        if (P === f) return it(!1);
        if (n = K(i = P), Ee(Y, r, f, e, i, n, t, !1) !== !1) return _t(), r.insertBefore(f, P), q = r, Pt(), it(!0);
      } else if (i.parentNode === r) {
        n = K(i);
        var Z, vt, et, at = f.parentNode !== r, kt = !function(k, Q, H) {
          var W = H ? k.left : k.top, dt = H ? k.right : k.bottom, j = H ? k.width : k.height, Lt = H ? Q.left : Q.top, Jt = H ? Q.right : Q.bottom, ht = H ? Q.width : Q.height;
          return W === Lt || dt === Jt || W + j / 2 === Lt + ht / 2;
        }(f.animated && f.toRect || e, i.animated && i.toRect || n, a), zt = a ? "top" : "left", rt = dn(i, "top", "top") || dn(f, "top", "top"), Tt = rt ? rt.scrollTop : void 0;
        if (Qt !== i && (vt = n[zt], re = !1, ye = !kt && c.invertSwap || at), Z = function(k, Q, H, W, dt, j, Lt, Jt) {
          var ht = W ? k.clientY : k.clientX, Dt = W ? H.height : H.width, l = W ? H.top : H.left, h = W ? H.bottom : H.right, d = !1;
          if (!Lt) {
            if (Jt && we < Dt * dt) {
              if (!re && (ae === 1 ? ht > l + Dt * j / 2 : ht < h - Dt * j / 2) && (re = !0), re) d = !0;
              else if (ae === 1 ? ht < l + we : ht > h - we) return -ae;
            } else if (ht > l + Dt * (1 - dt) / 2 && ht < h - Dt * (1 - dt) / 2) return function(_) {
              return Et(f) < Et(_) ? 1 : -1;
            }(Q);
          }
          return (d = d || Lt) && (ht < l + Dt * j / 2 || ht > h - Dt * j / 2) ? ht > l + Dt / 2 ? 1 : -1 : 0;
        }(t, i, n, a, kt ? 1 : c.swapThreshold, c.invertedSwapThreshold == null ? c.swapThreshold : c.invertedSwapThreshold, ye, Qt === i), Z !== 0) {
          var U = Et(f);
          do
            U -= Z, et = q.children[U];
          while (et && (T(et, "display") === "none" || et === x));
        }
        if (Z === 0 || et === i) return it(!1);
        Qt = i, ae = Z;
        var mt = i.nextElementSibling, z = !1, ut = Ee(Y, r, f, e, i, n, t, z = Z === 1);
        if (ut !== !1) return ut !== 1 && ut !== -1 || (z = ut === 1), Ze = !0, setTimeout(ro, 30), _t(), z && !mt ? r.appendChild(f) : i.parentNode.insertBefore(f, z ? mt : i), rt && On(rt, 0, Tt - rt.scrollTop), q = f.parentNode, vt === void 0 || ye || (we = Math.abs(vt - K(i)[zt])), Pt(), it(!0);
      }
      if (r.contains(f)) return it(!1);
    }
    return !1;
  }
  function gt(k, Q) {
    pt(k, b, Rt({ evt: t, isOwner: s, axis: a ? "vertical" : "horizontal", revert: o, dragRect: e, targetRect: n, canSort: g, fromSortable: C, target: i, completed: it, onMove: function(H, W) {
      return Ee(Y, r, f, e, H, K(H), t, W);
    }, changed: Pt }, Q));
  }
  function _t() {
    gt("dragOverAnimationCapture"), b.captureAnimationState(), b !== C && C.captureAnimationState();
  }
  function it(k) {
    return gt("dragOverCompleted", { insertion: k }), k && (s ? v._hideClone() : v._showClone(b), b !== C && (bt(f, tt ? tt.options.ghostClass : v.options.ghostClass, !1), bt(f, c.ghostClass, !0)), tt !== b && b !== S.active ? tt = b : b === S.active && tt && (tt = null), C === b && (b._ignoreWhileAnimating = i), b.animateAll(function() {
      gt("dragOverAnimationComplete"), b._ignoreWhileAnimating = null;
    }), b !== C && (C.animateAll(), C._ignoreWhileAnimating = null)), (i === f && !f.animated || i === r && !i.animated) && (Qt = null), c.dragoverBubble || t.rootEl || i === document || (f.parentNode[yt]._isOutsideThisEl(t.target), !k && Vt(t)), !c.dragoverBubble && t.stopPropagation && t.stopPropagation(), X = !0;
  }
  function Pt() {
    wt = Et(f), Yt = Et(f, c.draggable), st({ sortable: b, name: "change", toEl: r, newIndex: wt, newDraggableIndex: Yt, originalEvent: t });
  }
}, _ignoreWhileAnimating: null, _offMoveEvents: function() {
  N(document, "mousemove", this._onTouchMove), N(document, "touchmove", this._onTouchMove), N(document, "pointermove", this._onTouchMove), N(document, "dragover", Vt), N(document, "mousemove", Vt), N(document, "touchmove", Vt);
}, _offUpEvents: function() {
  var t = this.el.ownerDocument;
  N(t, "mouseup", this._onDrop), N(t, "touchend", this._onDrop), N(t, "pointerup", this._onDrop), N(t, "touchcancel", this._onDrop), N(document, "selectstart", this);
}, _onDrop: function(t) {
  var e = this.el, n = this.options;
  wt = Et(f), Yt = Et(f, n.draggable), pt("drop", this, { evt: t }), q = f && f.parentNode, wt = Et(f), Yt = Et(f, n.draggable), S.eventCanceled || (te = !1, ye = !1, re = !1, clearInterval(this._loopId), clearTimeout(this._dragStartTimer), je(this.cloneId), je(this._dragStartId), this.nativeDraggable && (N(document, "drop", this), N(e, "dragstart", this._onDragStart)), this._offMoveEvents(), this._offUpEvents(), ce && T(document.body, "user-select", ""), T(f, "transform", ""), t && (ie && (t.cancelable && t.preventDefault(), !n.dropBubble && t.stopPropagation()), x && x.parentNode && x.parentNode.removeChild(x), (Y === q || tt && tt.lastPutMode !== "clone") && $ && $.parentNode && $.parentNode.removeChild($), f && (this.nativeDraggable && N(f, "dragend", this), Ye(f), f.style["will-change"] = "", ie && !te && bt(f, tt ? tt.options.ghostClass : this.options.ghostClass, !1), bt(f, this.options.chosenClass, !1), st({ sortable: this, name: "unchoose", toEl: q, newIndex: null, newDraggableIndex: null, originalEvent: t }), Y !== q ? (wt >= 0 && (st({ rootEl: q, name: "add", toEl: q, fromEl: Y, originalEvent: t }), st({ sortable: this, name: "remove", toEl: q, originalEvent: t }), st({ rootEl: q, name: "sort", toEl: q, fromEl: Y, originalEvent: t }), st({ sortable: this, name: "sort", toEl: q, originalEvent: t })), tt && tt.save()) : wt !== ee && wt >= 0 && (st({ sortable: this, name: "update", toEl: q, originalEvent: t }), st({ sortable: this, name: "sort", toEl: q, originalEvent: t })), S.active && (wt != null && wt !== -1 || (wt = ee, Yt = de), st({ sortable: this, name: "end", toEl: q, originalEvent: t }), this.save())))), this._nulling();
}, _nulling: function() {
  pt("nulling", this), Y = f = q = x = Kt = $ = De = jt = Wt = Ct = ie = wt = Yt = ee = de = Qt = ae = tt = be = S.dragged = S.ghost = S.clone = S.active = null, Se.forEach(function(t) {
    t.checked = !0;
  }), Se.length = ze = Le = 0;
}, handleEvent: function(t) {
  switch (t.type) {
    case "drop":
    case "dragend":
      this._onDrop(t);
      break;
    case "dragenter":
    case "dragover":
      f && (this._onDragOver(t), function(e) {
        e.dataTransfer && (e.dataTransfer.dropEffect = "move"), e.cancelable && e.preventDefault();
      }(t));
      break;
    case "selectstart":
      t.preventDefault();
  }
}, toArray: function() {
  for (var t, e = [], n = this.el.children, o = 0, a = n.length, r = this.options; o < a; o++) Ot(t = n[o], r.draggable, this.el, !1) && e.push(t.getAttribute(r.dataIdAttr) || io(t));
  return e;
}, sort: function(t, e) {
  var n = {}, o = this.el;
  this.toArray().forEach(function(a, r) {
    var i = o.children[r];
    Ot(i, this.options.draggable, o, !1) && (n[a] = i);
  }, this), e && this.captureAnimationState(), t.forEach(function(a) {
    n[a] && (o.removeChild(n[a]), o.appendChild(n[a]));
  }), e && this.animateAll();
}, save: function() {
  var t = this.options.store;
  t && t.set && t.set(this);
}, closest: function(t, e) {
  return Ot(t, e || this.options.draggable, this.el, !1);
}, option: function(t, e) {
  var n = this.options;
  if (e === void 0) return n[t];
  var o = pe.modifyOption(this, t, e);
  n[t] = o !== void 0 ? o : e, t === "group" && Nn(n);
}, destroy: function() {
  pt("destroy", this);
  var t = this.el;
  t[yt] = null, N(t, "mousedown", this._onTapStart), N(t, "touchstart", this._onTapStart), N(t, "pointerdown", this._onTapStart), this.nativeDraggable && (N(t, "dragover", this), N(t, "dragenter", this)), Array.prototype.forEach.call(t.querySelectorAll("[draggable]"), function(e) {
    e.removeAttribute("draggable");
  }), this._onDrop(), this._disableDelayedDragEvents(), Me.splice(Me.indexOf(this.el), 1), this.el = t = null;
}, _hideClone: function() {
  if (!jt) {
    if (pt("hideClone", this), S.eventCanceled) return;
    T($, "display", "none"), this.options.removeCloneOnHide && $.parentNode && $.parentNode.removeChild($), jt = !0;
  }
}, _showClone: function(t) {
  if (t.lastPutMode === "clone") {
    if (jt) {
      if (pt("showClone", this), S.eventCanceled) return;
      f.parentNode != Y || this.options.group.revertClone ? Kt ? Y.insertBefore($, Kt) : Y.appendChild($) : Y.insertBefore($, f), this.options.group.revertClone && this.animate(f, $), T($, "display", ""), jt = !1;
    }
  } else this._hideClone();
} }, Re && F(document, "touchmove", function(t) {
  (S.active || te) && t.cancelable && t.preventDefault();
}), S.utils = { on: F, off: N, css: T, find: un, is: function(t, e) {
  return !!Ot(t, e, t, !1);
}, extend: function(t, e) {
  if (t && e) for (var n in e) e.hasOwnProperty(n) && (t[n] = e[n]);
  return t;
}, throttle: Cn, closest: Ot, toggleClass: bt, clone: pn, index: Et, nextTick: xe, cancelNextTick: je, detectDirection: Mn, getChild: oe }, S.get = function(t) {
  return t[yt];
}, S.mount = function() {
  for (var t = arguments.length, e = new Array(t), n = 0; n < t; n++) e[n] = arguments[n];
  e[0].constructor === Array && (e = e[0]), e.forEach(function(o) {
    if (!o.prototype || !o.prototype.constructor) throw "Sortable: Mounted plugin must be a constructor function, not ".concat({}.toString.call(o));
    o.utils && (S.utils = Rt(Rt({}, S.utils), o.utils)), pe.mount(o);
  });
}, S.create = function(t, e) {
  return new S(t, e);
}, S.version = "1.15.2";
var le, Qe, qe, $e, Ne, se, G = [], tn = !1;
function Ce() {
  G.forEach(function(t) {
    clearInterval(t.pid);
  }), G = [];
}
function bn() {
  clearInterval(se);
}
var We = Cn(function(t, e, n, o) {
  if (e.scroll) {
    var a, r = (t.touches ? t.touches[0] : t).clientX, i = (t.touches ? t.touches[0] : t).clientY, c = e.scrollSensitivity, u = e.scrollSpeed, v = It(), s = !1;
    Qe !== n && (Qe = n, Ce(), le = e.scroll, a = e.scrollFn, le === !0 && (le = qt(n, !0)));
    var g = 0, C = le;
    do {
      var b = C, X = K(b), R = X.top, P = X.bottom, Z = X.left, vt = X.right, et = X.width, at = X.height, kt = void 0, zt = void 0, rt = b.scrollWidth, Tt = b.scrollHeight, U = T(b), mt = b.scrollLeft, z = b.scrollTop;
      b === v ? (kt = et < rt && (U.overflowX === "auto" || U.overflowX === "scroll" || U.overflowX === "visible"), zt = at < Tt && (U.overflowY === "auto" || U.overflowY === "scroll" || U.overflowY === "visible")) : (kt = et < rt && (U.overflowX === "auto" || U.overflowX === "scroll"), zt = at < Tt && (U.overflowY === "auto" || U.overflowY === "scroll"));
      var ut = kt && (Math.abs(vt - r) <= c && mt + et < rt) - (Math.abs(Z - r) <= c && !!mt), gt = zt && (Math.abs(P - i) <= c && z + at < Tt) - (Math.abs(R - i) <= c && !!z);
      if (!G[g]) for (var _t = 0; _t <= g; _t++) G[_t] || (G[_t] = {});
      G[g].vx == ut && G[g].vy == gt && G[g].el === b || (G[g].el = b, G[g].vx = ut, G[g].vy = gt, clearInterval(G[g].pid), ut == 0 && gt == 0 || (s = !0, G[g].pid = setInterval((function() {
        o && this.layer === 0 && S.active._onTouchMove(Ne);
        var it = G[this.layer].vy ? G[this.layer].vy * u : 0, Pt = G[this.layer].vx ? G[this.layer].vx * u : 0;
        typeof a == "function" && a.call(S.dragged.parentNode[yt], Pt, it, t, Ne, G[this.layer].el) !== "continue" || On(G[this.layer].el, Pt, it);
      }).bind({ layer: g }), 24))), g++;
    } while (e.bubbleScroll && C !== v && (C = qt(C, !1)));
    tn = s;
  }
}, 30), wn = function(t) {
  var e = t.originalEvent, n = t.putSortable, o = t.dragEl, a = t.activeSortable, r = t.dispatchSortableEvent, i = t.hideGhostForTarget, c = t.unhideGhostForTarget;
  if (e) {
    var u = n || a;
    i();
    var v = e.changedTouches && e.changedTouches.length ? e.changedTouches[0] : e, s = document.elementFromPoint(v.clientX, v.clientY);
    c(), u && !u.el.contains(s) && (r("spill"), this.onSpill({ dragEl: o, putSortable: n }));
  }
};
function Ve() {
}
function Ge() {
}
function lo(t, e, n = {}) {
  let o;
  const { document: a = Jn, ...r } = n, i = { onUpdate: (s) => {
    (function(g, C, b) {
      const X = Hn(g), R = X ? [...Be(g)] : Be(g);
      if (b >= 0 && b < R.length) {
        const P = R.splice(C, 1)[0];
        Ut(() => {
          R.splice(b, 0, P), X && (g.value = R);
        });
      }
    })(e, s.oldIndex, s.newIndex);
  } }, c = () => {
    const s = typeof t == "string" ? a == null ? void 0 : a.querySelector(t) : function(g) {
      var C;
      const b = Be(g);
      return (C = b == null ? void 0 : b.$el) != null ? C : b;
    }(t);
    s && o === void 0 && (o = new S(s, { ...i, ...r }));
  }, u = () => {
    o == null || o.destroy(), o = void 0;
  };
  var v;
  return Un(c), v = u, Bn() && Fn(v), { stop: u, start: c, option: (s, g) => {
    if (g === void 0) return o == null ? void 0 : o.option(s);
    o == null || o.option(s, g);
  } };
}
function so() {
  var n;
  const t = nn("MaProTableOptions"), { renderPlugins: e = [] } = ((n = t == null ? void 0 : t.value) == null ? void 0 : n.provider) ?? { renderPlugins: [] };
  return { getPluginByName: (o) => e.find((a) => a.name === o), getPlugins: () => e, addPlugin: (o) => {
    e.find((a) => a.name === o.name) || e.push(o);
  }, removePlugin: (o) => {
    const a = e.findIndex((r) => r.name === o);
    a !== -1 && e.splice(a, 1);
  } };
}
Ve.prototype = { startIndex: null, dragStart: function(t) {
  var e = t.oldDraggableIndex;
  this.startIndex = e;
}, onSpill: function(t) {
  var e = t.dragEl, n = t.putSortable;
  this.sortable.captureAnimationState(), n && n.captureAnimationState();
  var o = oe(this.sortable.el, this.startIndex, this.options);
  o ? this.sortable.el.insertBefore(e, o) : this.sortable.el.appendChild(e), this.sortable.animateAll(), n && n.animateAll();
}, drop: wn }, At(Ve, { pluginName: "revertOnSpill" }), Ge.prototype = { onSpill: function(t) {
  var e = t.dragEl, n = t.putSortable || this.sortable;
  n.captureAnimationState(), e.parentNode && e.parentNode.removeChild(e), n.animateAll();
}, drop: wn }, At(Ge, { pluginName: "removeOnSpill" }), S.mount(new function() {
  function t() {
    for (var e in this.defaults = { scroll: !0, forceAutoScrollFallback: !1, scrollSensitivity: 30, scrollSpeed: 10, bubbleScroll: !0 }, this) e.charAt(0) === "_" && typeof this[e] == "function" && (this[e] = this[e].bind(this));
  }
  return t.prototype = { dragStarted: function(e) {
    var n = e.originalEvent;
    this.sortable.nativeDraggable ? F(document, "dragover", this._handleAutoScroll) : this.options.supportPointer ? F(document, "pointermove", this._handleFallbackAutoScroll) : n.touches ? F(document, "touchmove", this._handleFallbackAutoScroll) : F(document, "mousemove", this._handleFallbackAutoScroll);
  }, dragOverCompleted: function(e) {
    var n = e.originalEvent;
    this.options.dragOverBubble || n.rootEl || this._handleAutoScroll(n);
  }, drop: function() {
    this.sortable.nativeDraggable ? N(document, "dragover", this._handleAutoScroll) : (N(document, "pointermove", this._handleFallbackAutoScroll), N(document, "touchmove", this._handleFallbackAutoScroll), N(document, "mousemove", this._handleFallbackAutoScroll)), bn(), Ce(), clearTimeout(ue), ue = void 0;
  }, nulling: function() {
    Ne = Qe = le = tn = se = qe = $e = null, G.length = 0;
  }, _handleFallbackAutoScroll: function(e) {
    this._handleAutoScroll(e, !0);
  }, _handleAutoScroll: function(e, n) {
    var o = this, a = (e.touches ? e.touches[0] : e).clientX, r = (e.touches ? e.touches[0] : e).clientY, i = document.elementFromPoint(a, r);
    if (Ne = e, n || this.options.forceAutoScrollFallback || ve || Ht || ce) {
      We(e, this.options, i, n);
      var c = qt(i, !0);
      !tn || se && a === qe && r === $e || (se && bn(), se = setInterval(function() {
        var u = qt(document.elementFromPoint(a, r), !0);
        u !== c && (c = u, Ce()), We(e, o.options, u, n);
      }, 10), qe = a, $e = r);
    } else {
      if (!this.options.bubbleScroll || qt(i, !0) === It()) return void Ce();
      We(e, this.options, qt(i, !1), !1);
    }
  } }, At(t, { pluginName: "scroll", initializeByDefault: !0 });
}()), S.mount(Ge, Ve);
const $t = (t, e) => {
  const n = t.__vccOpts || t;
  for (const [o, a] of e) n[o] = a;
  return n;
}, co = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, uo = $t({ name: "IcBaselineDragIndicator" }, [["render", function(t, e, n, o, a, r) {
  return ft(), Ft("svg", co, e[0] || (e[0] = [St("path", { fill: "currentColor", d: "M11 18c0 1.1-.9 2-2 2s-2-.9-2-2s.9-2 2-2s2 .9 2 2m-2-8c-1.1 0-2 .9-2 2s.9 2 2 2s2-.9 2-2s-.9-2-2-2m0-6c-1.1 0-2 .9-2 2s.9 2 2 2s2-.9 2-2s-.9-2-2-2m6 4c1.1 0 2-.9 2-2s-.9-2-2-2s-2 .9-2 2s.9 2 2 2m0 2c-1.1 0-2 .9-2 2s.9 2 2 2s2-.9 2-2s-.9-2-2-2m0 6c-1.1 0-2 .9-2 2s.9 2 2 2s2-.9 2-2s-.9-2-2-2" }, null, -1)]));
}]]), ho = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, yn = $t({ name: "RiMoreLine" }, [["render", function(t, e, n, o, a, r) {
  return ft(), Ft("svg", ho, e[0] || (e[0] = [St("path", { fill: "currentColor", d: "M4.5 10.5c-.825 0-1.5.675-1.5 1.5s.675 1.5 1.5 1.5S6 12.825 6 12s-.675-1.5-1.5-1.5m15 0c-.825 0-1.5.675-1.5 1.5s.675 1.5 1.5 1.5S21 12.825 21 12s-.675-1.5-1.5-1.5m-7.5 0c-.825 0-1.5.675-1.5 1.5s.675 1.5 1.5 1.5s1.5-.675 1.5-1.5s-.675-1.5-1.5-1.5" }, null, -1)]));
}]]);
function _e(t) {
  return typeof t == "function" || Object.prototype.toString.call(t) === "[object Object]" && !qn(t);
}
const Sn = fe({ name: "MaProTable", props: { options: { type: Object, default: () => ({ tableOptions: {}, searchOptions: {}, searchFormOptions: {} }) }, schema: { type: Object, default: () => ({ searchItems: [], tableColumns: [] }) } }, emits: ["row-drag-sort", "search-submit", "search-reset"], setup(t, { slots: e, emit: n, expose: o }) {
  var Lt, Jt, ht, Dt;
  const a = nn("MaProTableOptions"), r = ge(() => {
    const l = [];
    return rn(a.value.provider.toolbars, (h) => h.order ?? 0).map((h) => {
      (xt(h.show) ? h.show : () => h.show !== !1)() && l.push(h);
    }), l;
  }), i = ct([]);
  ct([]);
  const c = ct(!1), u = `_${Math.floor(1e5 * Math.random() + 2e4 * Math.random() + 5e3 * Math.random())}`, v = Tn(), s = ct(t.options), g = ct(t.schema), C = ct(((Lt = g.value) == null ? void 0 : Lt.tableColumns) ?? []), b = ct(((Jt = s.value) == null ? void 0 : Jt.requestOptions) ?? {}), X = ct(!0), R = ct(((Dt = (ht = s.value) == null ? void 0 : ht.requestOptions) == null ? void 0 : Dt.requestParams) ?? {}), P = zn([]), Z = ct(), vt = ge(() => {
    var l;
    return ((l = b.value) == null ? void 0 : l.autoRequest) ?? !0;
  }), et = async () => {
    var _, w, E;
    const { pageName: l = "page", sizeName: h = "page_size", size: d = 10 } = ((w = (_ = s.value) == null ? void 0 : _.requestOptions) == null ? void 0 : w.requestPage) ?? {};
    R.value[l] = 1, R.value[h] = d, Z.value = { pageName: l, sizeName: h, size: d }, await Ut(() => {
      var O, A;
      return U(((A = (O = mt()) == null ? void 0 : O.getSearchForm) == null ? void 0 : A.call(O)) ?? {});
    }), vt.value && z().setPagination({ defaultPageSize: (E = Z.value) == null ? void 0 : E.size, onChange: async (O, A) => {
      R.value[l] = O, R.value[h] = A, await Tt(), zt();
    } });
  }, at = ct([]), { actionBtnPosition: kt = "auto" } = s.value, zt = () => {
    var _, w, E, O;
    const { tableOptions: l } = s.value, h = xt(l == null ? void 0 : l.rowKey) ? (_ = l == null ? void 0 : l.rowKey) == null ? void 0 : _.call(l, {}) : (l == null ? void 0 : l.rowKey) ?? "id", d = (O = (E = (w = z()) == null ? void 0 : w.getElTableRef()) == null ? void 0 : E.store) == null ? void 0 : O.states;
    if (i.value.length > 0 && d.data.value) {
      const A = i.value.filter((I) => d.data.value.find((M) => I[h] === M[h])), B = z().getElTableRef();
      A.map((I) => {
        var M;
        return (M = B == null ? void 0 : B.toggleRowSelection) == null ? void 0 : M.call(B, I, !0);
      });
    }
  }, rt = ge(() => (() => {
    var d, _;
    const { header: l, toolbar: h } = s.value;
    return { headerShowFun: typeof (l == null ? void 0 : l.show) == "function" ? l.show : () => (l == null ? void 0 : l.show) !== !1, toolbarShowFun: typeof h == "function" ? h : () => h !== !1, searchIsShow: ((_ = (d = mt()) == null ? void 0 : d.getShowState) == null ? void 0 : _.call(d)) ?? !0 };
  })()), Tt = async () => {
    var l, h, d, _, w, E, O, A;
    if ((((l = b.value) == null ? void 0 : l.autoRequest) ?? 1) || (b.value.autoRequest = !0, await et()), (h = b.value) == null ? void 0 : h.api) if (vt.value) {
      const { response: B, data: I, total: M } = await (async () => new Promise((lt, p) => {
        var m;
        z().setLoadingState(!0), (m = b.value) == null || m.api(R.value).then((D) => {
          var nt, Mt, Xt, me;
          const L = D.data[((Mt = (nt = b.value) == null ? void 0 : nt.response) == null ? void 0 : Mt.dataKey) ?? "list"] ?? [], J = D.data[((me = (Xt = b.value) == null ? void 0 : Xt.response) == null ? void 0 : me.totalKey) ?? "total"] ?? 0;
          z().setLoadingState(!1), lt({ response: D.data, data: L, total: J });
        }).catch(() => {
          z().setLoadingState(!1), p({ response: null, data: [], total: 0 });
        });
      }))();
      z().setData(((_ = (d = b.value) == null ? void 0 : d.responseDataHandler) == null ? void 0 : _.call(d, B)) ?? I), M && M > 0 ? (z().setOptions({ showPagination: !0 }), z().setPagination(Object.assign(((E = (w = s.value) == null ? void 0 : w.tableOptions) == null ? void 0 : E.pagination) ?? {}, { total: M }))) : z().setOptions({ showPagination: !1 }), P.value = I;
    } else P.value = [];
    else {
      const B = ((A = (O = s.value) == null ? void 0 : O.tableOptions) == null ? void 0 : A.data) ?? [];
      z().setData(B), P.value = B;
    }
  }, U = async (l, h = !1) => {
    R.value = Object.assign(R.value, l), h && await Tt();
  }, mt = () => {
    var l;
    return (l = v == null ? void 0 : v.proxy) == null ? void 0 : l.$refs[`MaSearchRef${u}`];
  }, z = () => {
    var l;
    return (l = v == null ? void 0 : v.proxy) == null ? void 0 : l.$refs[`MaTableRef${u}`];
  }, ut = async () => {
    var h, d, _, w, E, O, A, B, I, M, lt;
    await Ut();
    const l = document.querySelector(`.ma-pro-table .mine-ptt${u} .ma-pagination`);
    if ((h = l == null ? void 0 : l.classList) == null || h.add("no-print"), ((_ = (d = s.value) == null ? void 0 : d.tableOptions) == null ? void 0 : _.adaption) ?? 1) {
      const { headerShowFun: p, toolbarShowFun: m } = rt.value, D = ((w = document.querySelector(`.ma-pro-table .ma-pro-table-search${u}`)) == null ? void 0 : w.offsetHeight) ?? 0, L = ((E = document.querySelector(`.ma-pro-table .ma-pro-table-header${u}`)) == null ? void 0 : E.offsetHeight) ?? 0, J = ((O = document.querySelector(`.ma-pro-table .ma-pro-table-tool${u}`)) == null ? void 0 : O.offsetHeight) ?? 0, nt = (l == null ? void 0 : l.offsetHeight) ?? -35;
      z().setOptions({ adaptionOffsetBottom: (((B = (A = g.value) == null ? void 0 : A.searchItems) == null ? void 0 : B.length) > 0 && mt().getShowState() ? D : -12) + (p() ? L + 30 : 0) + (m() ? J + 10 : 0) + nt + (((I = s == null ? void 0 : s.value) == null ? void 0 : I.adaptionOffsetBottom) ?? 0) + 16 });
    }
    document.body.clientWidth < 1e3 ? (M = z()) == null || M.setPagination({ size: "small", layout: "prev, pager, next, sizes" }) : (lt = z()) == null || lt.setPagination({ size: "default", layout: void 0 });
  }, gt = () => {
    var l;
    return y("div", null, [(l = e.actions) == null ? void 0 : l.call(e)]);
  }, _t = () => {
    var d, _, w;
    const { header: l } = s.value, { headerShowFun: h } = rt.value;
    return y(Gt, null, [h() && y("div", { className: `mine-card ma-pro-table-header ma-pro-table-header${u}` }, [((d = e.tableHeader) == null ? void 0 : d.call(e)) ?? y(Gt, null, [y("div", { className: "ma-pro-table-header-title" }, [((_ = e.headerTitle) == null ? void 0 : _.call(e)) ?? y(Gt, null, [y("div", { className: "main-title" }, [xt(l == null ? void 0 : l.mainTitle) ? l.mainTitle() : (l == null ? void 0 : l.mainTitle) ?? "表格主标题"]), y("div", { className: "secondary-title" }, [xt(l == null ? void 0 : l.subTitle) ? l.subTitle() : (l == null ? void 0 : l.subTitle) ?? ""])])]), y("div", { className: "ma-pro-table-header-actions" }, [["auto", "header"].includes(kt) && gt(), (w = e.headerRight) == null ? void 0 : w.call(e)])])])]);
  }, it = () => {
    var E, O, A, B;
    const { selection: l, toolStates: h } = s.value, d = ge(() => (xt(l == null ? void 0 : l.selectedText) ? l.selectedText() : (l == null ? void 0 : l.selectedText) ?? "已选择 {number} 项").replace("{number}", i.value.length.toString())), { headerShowFun: _, toolbarShowFun: w } = rt.value;
    return y("div", { className: `ma-pro-table-toolbar ma-pro-table-tool${u}` }, [y("div", { className: "ma-pro-table-toolbar-content" }, [(E = e.toolbarLeft) == null ? void 0 : E.call(e), (!_() || kt === "table") && w() && gt(), l && ((l == null ? void 0 : l.crossPage) ?? !1) && y("div", { class: "ma-pro-table-selection-all" }, [d.value, y(V("el-link"), { underline: "never", type: "primary", onClick: () => {
      var I, M, lt;
      (lt = (M = (I = z()) == null ? void 0 : I.getElTableRef()) == null ? void 0 : M.clearSelection) == null || lt.call(M), i.value = [];
    } }, { default: () => [xt(l == null ? void 0 : l.clearText) ? l.clearText() : (l == null ? void 0 : l.clearText) ?? "清除选择"] })])]), y("div", null, [(O = e.beforeToolbar) == null ? void 0 : O.call(e), ((A = e.toolbar) == null ? void 0 : A.call(e)) ?? y(Gt, null, [r.value.filter((I) => {
      if (!h) return !0;
      const M = h[I.name] ?? void 0;
      return M === void 0 || (typeof M == "function" ? M == null ? void 0 : M() : M);
    }).map((I) => Ke(I.render(), { proxy: j.value }))]), (B = e.afterToolbar) == null ? void 0 : B.call(e)])]);
  }, Pt = (l, h) => {
    l.map((d, _) => {
      var E, O, A, B;
      const w = xt(d == null ? void 0 : d.prop) ? d.prop(_) : (d == null ? void 0 : d.prop) ?? "";
      if ((xt(d == null ? void 0 : d.isRender) ? d.isRender() : (d == null ? void 0 : d.isRender) ?? !0) || l.splice(_, 1), ((E = d == null ? void 0 : d.children) == null ? void 0 : E.length) > 0) Pt(d.children, h);
      else if (d != null && d.cellRenderTo) {
        const I = h(d.cellRenderTo.name);
        I && ((O = d.cellRenderTo) != null && O.props ? (B = (A = d.cellRenderTo) == null ? void 0 : A.props) != null && B.prop || (d.cellRenderTo.props.prop = w) : d.cellRenderTo.props = { prop: w }, d.cellRender = (M) => I.render(M, d.cellRenderTo.props, j.value));
      }
      d.cellRenderPro && (d.cellRender = (I) => d.cellRenderPro(I, j.value)), d.headerRenderPro && (d.headerRender = (I) => d.headerRenderPro(I, j.value));
    });
  }, k = () => {
    const l = C.value.find((w) => (w == null ? void 0 : w.type) === "sort"), h = C.value.find((w) => (w == null ? void 0 : w.type) === "operation"), d = C.value.find((w) => (w == null ? void 0 : w.type) === "selection"), _ = C.value.find((w) => (w == null ? void 0 : w.type) === "index");
    l && (l != null && l.label || l != null && l.headerRender || (l.label = "行排序"), l.width = (l == null ? void 0 : l.width) ?? "50px", l.showOverflowTooltip = !1, l.cellRender = () => y("div", { className: "mine-cell-flex-center mine-cursor-resize" }, [y(uo, null, null)])), h && (h != null && h.label || h != null && h.headerRender || (h.label = "操作"), h.showOverflowTooltip = !1, h != null && h.cellRender || (h.cellRender = (w) => ((E, O) => {
      const { type: A = "auto", fold: B = 1 } = (O == null ? void 0 : O.operationConfigure) ?? {}, I = (p) => {
        var m;
        return y(Gt, null, [(p == null ? void 0 : p.icon) && ((m = a.value.provider) == null ? void 0 : m.icon) && Ke(a.value.provider.icon, { style: "margin-right: 2px;", name: xt(p.icon) ? p.icon(E) : p.icon }), xt(p.text) ? p.text(E) : (p == null ? void 0 : p.text) ?? "unknown"]);
      }, M = (p, m) => {
        var L, J;
        let D;
        return (((L = p == null ? void 0 : p.show) == null ? void 0 : L.call(p, m)) ?? !0) && y(V("el-link"), an({ underline: "never" }, p == null ? void 0 : p.linkProps, { disabled: ((J = p == null ? void 0 : p.disabled) == null ? void 0 : J.call(p, m)) ?? !1, onClick: (nt) => {
          var Mt;
          return (Mt = p == null ? void 0 : p.onClick) == null ? void 0 : Mt.call(p, m, j.value, nt);
        } }), _e(D = I(p)) ? D : { default: () => [D] });
      }, lt = (p, m) => {
        var J;
        let D;
        const L = ((J = p == null ? void 0 : p.disabled) == null ? void 0 : J.call(p, m)) ?? !1;
        return y(V("el-dropdown-item"), { disabled: L, command: p }, { default: () => [y(V("el-link"), an({ underline: "never" }, p == null ? void 0 : p.linkProps, { disabled: L }), _e(D = I(p)) ? D : { default: () => [D] })] });
      };
      if (A === "auto") {
        const p = [];
        return y("div", { className: "mine-operation-scroll" }, [at.value.map((m, D) => {
          var L, J;
          return D + 1 <= B ? ((L = m == null ? void 0 : m.show) == null ? void 0 : L.call(m, E)) ?? 1 ? M(m, E) : null : ((((J = m == null ? void 0 : m.show) == null ? void 0 : J.call(m, E)) ?? 1) && p.push(m), null);
        }), p.length > 0 && y(V("el-dropdown"), { "hide-on-click": !1, onCommand: (m) => {
          var D;
          return (D = m.onClick) == null ? void 0 : D.call(m, E, j.value);
        } }, { default: () => [y(V("el-link"), { underline: "never" }, { default: () => [y(yn, null, null)] })], dropdown: () => {
          let m;
          return y(V("el-dropdown-menu"), null, _e(m = p.map((D) => {
            var L;
            return ((L = D == null ? void 0 : D.show) == null ? void 0 : L.call(D, E)) ?? 1 ? lt(D, E) : null;
          })) ? m : { default: () => [m] });
        } })]);
      }
      return A === "dropdown" ? y("div", { className: "mine-operation-scroll" }, [y(V("el-dropdown"), { "hide-on-click": !1, onCommand: (p) => {
        var m;
        return (m = p.onClick) == null ? void 0 : m.call(p, E, j.value);
      } }, { default: () => [y(V("el-link"), { underline: "never" }, { default: () => [y(yn, null, null)] })], dropdown: () => {
        let p;
        return y(V("el-dropdown-menu"), null, _e(p = at.value.map((m) => {
          var D;
          return ((D = m == null ? void 0 : m.show) == null ? void 0 : D.call(m, E)) ?? 1 ? lt(m, E) : null;
        })) ? p : { default: () => [p] });
      } })]) : A === "tile" ? y("div", { className: "mine-operation-scroll" }, [at.value.map((p) => {
        var m;
        return ((m = p == null ? void 0 : p.show) == null ? void 0 : m.call(p, E)) ?? 1 ? M(p, E) : null;
      })]) : void 0;
    })(w, h))), d && (d.label = (d == null ? void 0 : d.label) ?? "多选"), _ && (_.label = (_ == null ? void 0 : _.label) ?? "#");
  }, Q = () => {
    var l, h, d, _, w, E, O, A;
    (((h = (l = s.value) == null ? void 0 : l.tableOptions) == null ? void 0 : h.adaption) ?? 1) && (s.value.tableOptions = Object.assign(((d = s.value) == null ? void 0 : d.tableOptions) ?? {}, { maxHeight: void 0 })), (() => {
      var I, M;
      const { rowContextMenu: B } = s.value;
      ((B == null ? void 0 : B.enabled) ?? !1) === !0 && ((I = a.value.provider) != null && I.contextMenu) && (s.value.tableOptions || (s.value.tableOptions = {}), s.value.tableOptions.on = ((M = s.value.tableOptions) == null ? void 0 : M.on) ?? {}, s.value.tableOptions.on.onRowContextmenu = (lt, p, m) => {
        var L, J;
        m.preventDefault(), m.stopPropagation();
        const D = [];
        (L = B == null ? void 0 : B.items) == null || L.map((nt, Mt) => {
          nt.onClick = () => {
            var Xt;
            (Xt = nt == null ? void 0 : nt.onMenuClick) == null || Xt.call(nt, { row: lt, column: p, proxy: j.value }, m);
          }, D.push(nt);
        }), (J = a.value.provider) == null || J.contextMenu({ x: m.x, y: m.y, zIndex: 1050, iconFontClass: "", customClass: "mine-contextmenu", items: D });
      });
    })(), (E = z()) == null || E.setOptions({ adaption: ((w = (_ = s.value) == null ? void 0 : _.tableOptions) == null ? void 0 : w.adaption) ?? !0 }), (A = z()) == null || A.setOptions(Object.assign(((O = s.value) == null ? void 0 : O.tableOptions) ?? {}));
  }, H = () => {
    const { getPluginByName: l } = so();
    Ut(() => {
      var d, _, w;
      const h = (d = C.value) == null ? void 0 : d.find((E) => (E == null ? void 0 : E.type) === "operation");
      at.value = ((_ = h == null ? void 0 : h.operationConfigure) == null ? void 0 : _.actions) ?? [], at.value = rn(at.value, (E) => E.order), Pt(C.value, l), k(), (w = z()) == null || w.setColumns(C.value);
    });
  }, W = () => {
    var h, d, _, w, E, O, A, B, I, M, lt;
    const { toolbarShowFun: l } = rt.value;
    return y(Gt, null, [((d = (h = g.value) == null ? void 0 : h.searchItems) == null ? void 0 : d.length) > 0 && Yn(y("div", { className: `ma-pro-table-search mine-card ma-pro-table-search${u}` }, [y(V("ma-search"), { ref: `MaSearchRef${u}`, options: s.value.searchOptions, "form-options": s.value.searchFormOptions, "search-items": g.value.searchItems, onFold: async () => await ut(), onSearch: async (p) => {
      var m, D, L;
      (m = s.value) != null && m.onSearchSubmit && (p = (L = (D = s.value).onSearchSubmit) == null ? void 0 : L.call(D, p)), n("search-submit", p), await U(p, !0);
    }, onReset: async (p) => {
      var m, D, L;
      (m = s.value) != null && m.onSearchReset && (p = (L = (D = s.value).onSearchReset) == null ? void 0 : L.call(D, p)), n("search-reset", p), await U(p, !0);
    } }, { default: ((_ = e.search) == null ? void 0 : _.call(e)) ?? void 0, actions: ((w = e.searchActions) == null ? void 0 : w.call(e)) ?? void 0, beforeActions: ((E = e.searchBeforeActions) == null ? void 0 : E.call(e)) ?? void 0, afterActions: ((O = e.searchAfterActions) == null ? void 0 : O.call(e)) ?? void 0 })]), [[jn, (((A = s.value.searchOptions) == null ? void 0 : A.show) ?? !0) && rt.value.searchIsShow]]), (B = e.middle) == null ? void 0 : B.call(e), y("div", { className: `mine-card mine-ptt${u}` }, [((I = e.tableTop) == null ? void 0 : I.call(e)) ?? void 0, l() && it(), ((M = e.tableCranny) == null ? void 0 : M.call(e)) ?? void 0, X.value && y(V("ma-table"), { id: `ma-table${u}`, class: "ma-pro-table", ref: `MaTableRef${u}`, onSelectionChange: (p) => {
      var L, J;
      const { tableOptions: m, selection: D } = s.value;
      if (D != null && D.crossPage) {
        const nt = xt(m == null ? void 0 : m.rowKey) ? (L = m == null ? void 0 : m.rowKey) == null ? void 0 : L.call(m, {}) : (m == null ? void 0 : m.rowKey) ?? "id";
        i.value.push(...p), i.value = ((Mt, Xt) => {
          const me = Mt.reduce((Ie, ke) => {
            const on = Xt ? Xt(ke) : ke;
            return Ie[on] || (Ie[on] = ke), Ie;
          }, {});
          return Object.values(me);
        })(i.value, (Mt) => Mt[nt]);
      }
      ((J = s.value.selection) == null ? void 0 : J.crossPage) === !0 && s.value.tableOptions.on.onSelectionChange(i.value);
    }, onSetDataCallback: (p) => P.value = p }, { default: ((lt = e.default) == null ? void 0 : lt.call(e)) ?? void 0, ...e })])]);
  }, dt = () => y("div", { className: "ma-pro-table" }, [_t(), W()]);
  en(async () => {
    var d;
    c.value = !0;
    const l = ((d = b.value) == null ? void 0 : d.autoRequest) ?? !0;
    H(), Q(), l && await et(), l && await Tt(), window.addEventListener("resize", ut), await ut();
    const h = ct(document.querySelector(`.mine-ptt${u} tbody`));
    Ln(() => X.value, (_) => {
      if (_) {
        h.value = document.querySelector(`.mine-ptt${u} tbody`);
        const w = JSON.parse(JSON.stringify(P.value));
        lo(h, w, { handle: ".mine-cursor-resize", animation: 300, onEnd: async () => {
          var E, O, A;
          await Ut(() => P.value = w), (A = (O = (E = s.value) == null ? void 0 : E.on) == null ? void 0 : O.rowDragSort) == null || A.call(O, w), n("row-drag-sort", w);
        } });
      }
    }, { immediate: !0 });
  }), Xn(() => {
    window.removeEventListener("resize", ut);
  });
  const j = ct({ getSearchRef: () => mt(), getTableRef: () => z(), getElTableStates: () => {
    var l, h, d;
    return (d = (h = (l = z()) == null ? void 0 : l.getElTableRef()) == null ? void 0 : h.store) == null ? void 0 : d.states;
  }, setTableColumns: (l) => {
    C.value = l, H();
  }, getTableColumns: () => C.value, setSearchForm: (l) => {
    var h, d;
    return (d = (h = mt()) == null ? void 0 : h.setSearchForm) == null ? void 0 : d.call(h, l);
  }, getSearchForm: () => {
    var l, h;
    return (h = (l = mt()) == null ? void 0 : l.getSearchForm) == null ? void 0 : h.call(l);
  }, search: async (l) => {
    var h, d;
    return await U(Object.assign((d = (h = mt()) == null ? void 0 : h.getSearchForm) == null ? void 0 : d.call(h), l ?? {}), !0);
  }, refresh: async () => await Tt(), getProTableOptions: () => s.value, setProTableOptions: (l) => {
    Object.assign(s.value, l ?? {}), Q();
  }, getCurrentId: () => u, requestData: Tt, changeApi: async (l, h = !0) => {
    b.value.api = l, h && (await et(), await Tt());
  }, setRequestParams: U, resizeHeight: ut });
  return o({ ...j.value }), () => a.value.ssr ? c.value && dt() : dt();
} });
function zo() {
  var o;
  const t = nn("MaProTableOptions"), { toolbars: e = [] } = (o = t.value) == null ? void 0 : o.provider, n = (a) => e.find((r) => r.name === a);
  return { get: n, getAll: () => e, add: (a) => {
    e.find((r) => r.name === a.name) || e.push(a);
  }, remove: (a) => {
    const r = e.findIndex((i) => i.name === a);
    r !== -1 && e.splice(r, 1);
  }, hide: (a) => {
    n(a).show = !1;
  }, show: (a) => {
    n(a).show = !0;
  } };
}
const po = [{ name: "tag", render: (t, e, n) => Ke(Gn, e, { default: () => t.row[e == null ? void 0 : e.prop] }) }], fo = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, vo = $t({ name: "IcOutlineRefresh" }, [["render", function(t, e, n, o, a, r) {
  return ft(), Ft("svg", fo, e[0] || (e[0] = [St("path", { fill: "currentColor", d: "M17.65 6.35A7.96 7.96 0 0 0 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08A5.99 5.99 0 0 1 12 18c-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4z" }, null, -1)]));
}]]), mo = fe({ __name: "proTableRefresh", props: { proxy: {} }, setup(t) {
  const e = async () => {
    await t.proxy.requestData();
  };
  return (n, o) => {
    const a = V("el-button");
    return ft(), he(a, { circle: "", onClick: e }, { default: Nt(() => [y(vo)]), _: 1 });
  };
} }), go = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, bo = $t({ name: "IcRoundSearch" }, [["render", function(t, e, n, o, a, r) {
  return ft(), Ft("svg", go, e[0] || (e[0] = [St("path", { fill: "currentColor", d: "M15.5 14h-.79l-.28-.27a6.5 6.5 0 0 0 1.48-5.34c-.47-2.78-2.79-5-5.59-5.34a6.505 6.505 0 0 0-7.27 7.27c.34 2.8 2.56 5.12 5.34 5.59a6.5 6.5 0 0 0 5.34-1.48l.27.28v.79l4.25 4.25c.41.41 1.08.41 1.49 0c.41-.41.41-1.08 0-1.49zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5S14 7.01 14 9.5S11.99 14 9.5 14" }, null, -1)]));
}]]), wo = fe({ __name: "proTableSearch", props: { proxy: {} }, setup(t) {
  const e = async () => {
    t.proxy.getSearchRef().setShowState(!t.proxy.getSearchRef().getShowState()), document.querySelector(`.ma-pro-table-search${t.proxy.getCurrentId()}`).style.display = t.proxy.getSearchRef().getShowState() ? "block" : "none", await t.proxy.resizeHeight();
  };
  return (n, o) => {
    const a = V("el-button");
    return ft(), he(a, { circle: "", onClick: e }, { default: Nt(() => [y(bo)]), _: 1 });
  };
} });
class yo {
  constructor(e, n = {}) {
    Ae(this, "dom", null);
    Ae(this, "options", { noPrint: void 0 });
    if (this.options = this.extend({ noPrint: ".no-print" }, n), typeof e == "string") try {
      this.dom = document.querySelector(e);
    } catch {
      this.dom = document.createElement("div"), this.dom.innerHTML = e;
    }
    else this.isDOM(e), this.dom = this.isDOM(e) ? e : e.$el;
    this.init();
  }
  init() {
    this.writeIframe(this.getStyle() + this.getHtml());
  }
  extend(e, n) {
    for (let o in n) e[o] = n[o];
    return e;
  }
  getStyle() {
    var o;
    let e = "", n = document.querySelectorAll("style,link");
    for (let a = 0; a < n.length; a++) e += n[a].outerHTML;
    return e += "<style>" + (((o = this.options) == null ? void 0 : o.noPrint) ?? ".no-print") + "{ display: none; }</style>", e += "<style>html, body{ background-color: #fff; }</style>", e;
  }
  getHtml() {
    var a;
    const e = document.querySelectorAll("input"), n = document.querySelectorAll("textarea"), o = document.querySelectorAll("select");
    for (let r = 0; r < e.length; r++) e[r].type === "checkbox" || e[r].type === "radio" ? e[r].checked === !0 ? e[r].setAttribute("checked", "checked") : e[r].removeAttribute("checked") : (e[r].type, e[r].setAttribute("value", e[r].value));
    for (let r = 0; r < n.length; r++) n[r].type === "textarea" && (n[r].innerHTML = n[r].value);
    for (let r = 0; r < o.length; r++) if (o[r].type === "select-one") {
      let i = o[r].children;
      for (let c in i) i[c].tagName === "OPTION" && (((a = i[c]) == null ? void 0 : a.selected) === !0 ? i[c].setAttribute("selected", "selected") : i[c].removeAttribute("selected"));
    }
    return this.dom.outerHTML;
  }
  writeIframe(e) {
    let n, o, a = document.createElement("iframe"), r = document.body.appendChild(a);
    a.id = "myIframe", a.setAttribute("style", "position:absolute; width:0; height:0; top:-10px; left:-10px;"), n = r.contentWindow ?? r.contentDocument, o = r.contentDocument ?? r.contentWindow.document, o.open(), o.write(e), o.close();
    const i = this;
    a.onload = () => {
      i.toPrint(n), setTimeout(() => {
        document.body.removeChild(a);
      }, 100);
    };
  }
  toPrint(e) {
    try {
      setTimeout(() => {
        e.focus();
        try {
          e.document.execCommand("print", !1, null) || e.print();
        } catch {
          e.print();
        }
        e.close();
      }, 10);
    } catch {
    }
  }
  isDOM(e) {
    return typeof HTMLElement == "object" ? e instanceof HTMLElement : e && typeof e == "object" && e.nodeType === 1 && typeof e.nodeName == "string";
  }
}
const So = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, To = $t({ name: "IcOutlinePrint" }, [["render", function(t, e, n, o, a, r) {
  return ft(), Ft("svg", So, e[0] || (e[0] = [St("path", { fill: "currentColor", d: "M19 8h-1V3H6v5H5c-1.66 0-3 1.34-3 3v6h4v4h12v-4h4v-6c0-1.66-1.34-3-3-3M8 5h8v3H8zm8 12v2H8v-4h8zm2-2v-2H6v2H4v-4c0-.55.45-1 1-1h14c.55 0 1 .45 1 1v4z" }, null, -1), St("circle", { cx: "18", cy: "11.5", r: "1", fill: "currentColor" }, null, -1)]));
}]]), Eo = fe({ __name: "proTablePrint", props: { proxy: {} }, setup(t) {
  const e = () => {
    new yo(document.querySelector(`#ma-table${t.proxy.getCurrentId()}`));
  };
  return (n, o) => {
    const a = V("el-button");
    return ft(), he(a, { circle: "", onClick: e }, { default: Nt(() => [y(To)]), _: 1 });
  };
} }), xo = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, _o = $t({ name: "IcOutlineSettings" }, [["render", function(t, e, n, o, a, r) {
  return ft(), Ft("svg", xo, e[0] || (e[0] = [St("path", { fill: "currentColor", d: "M19.43 12.98c.04-.32.07-.64.07-.98c0-.34-.03-.66-.07-.98l2.11-1.65c.19-.15.24-.42.12-.64l-2-3.46a.5.5 0 0 0-.61-.22l-2.49 1c-.52-.4-1.08-.73-1.69-.98l-.38-2.65A.488.488 0 0 0 14 2h-4c-.25 0-.46.18-.49.42l-.38 2.65c-.61.25-1.17.59-1.69.98l-2.49-1a.566.566 0 0 0-.18-.03c-.17 0-.34.09-.43.25l-2 3.46c-.13.22-.07.49.12.64l2.11 1.65c-.04.32-.07.65-.07.98c0 .33.03.66.07.98l-2.11 1.65c-.19.15-.24.42-.12.64l2 3.46a.5.5 0 0 0 .61.22l2.49-1c.52.4 1.08.73 1.69.98l.38 2.65c.03.24.24.42.49.42h4c.25 0 .46-.18.49-.42l.38-2.65c.61-.25 1.17-.59 1.69-.98l2.49 1c.06.02.12.03.18.03c.17 0 .34-.09.43-.25l2-3.46c.12-.22.07-.49-.12-.64zm-1.98-1.71c.04.31.05.52.05.73c0 .21-.02.43-.05.73l-.14 1.13l.89.7l1.08.84l-.7 1.21l-1.27-.51l-1.04-.42l-.9.68c-.43.32-.84.56-1.25.73l-1.06.43l-.16 1.13l-.2 1.35h-1.4l-.19-1.35l-.16-1.13l-1.06-.43c-.43-.18-.83-.41-1.23-.71l-.91-.7l-1.06.43l-1.27.51l-.7-1.21l1.08-.84l.89-.7l-.14-1.13c-.03-.31-.05-.54-.05-.74s.02-.43.05-.73l.14-1.13l-.89-.7l-1.08-.84l.7-1.21l1.27.51l1.04.42l.9-.68c.43-.32.84-.56 1.25-.73l1.06-.43l.16-1.13l.2-1.35h1.39l.19 1.35l.16 1.13l1.06.43c.43.18.83.41 1.23.71l.91.7l1.06-.43l1.27-.51l.7 1.21l-1.07.85l-.89.7zM12 8c-2.21 0-4 1.79-4 4s1.79 4 4 4s4-1.79 4-4s-1.79-4-4-4m0 6c-1.1 0-2-.9-2-2s.9-2 2-2s2 .9 2 2s-.9 2-2 2" }, null, -1)]));
}]]), Do = { xmlns: "http://www.w3.org/2000/svg", width: "1.5em", height: "1.5em", viewBox: "0 0 24 24" }, Co = $t({ name: "IcRoundFirstPage" }, [["render", function(t, e, n, o, a, r) {
  return ft(), Ft("svg", Do, e[0] || (e[0] = [St("path", { fill: "currentColor", d: "M17.7 15.89L13.82 12l3.89-3.89A.996.996 0 1 0 16.3 6.7l-4.59 4.59a.996.996 0 0 0 0 1.41l4.59 4.59c.39.39 1.02.39 1.41 0a.993.993 0 0 0-.01-1.4M7 6c.55 0 1 .45 1 1v10c0 .55-.45 1-1 1s-1-.45-1-1V7c0-.55.45-1 1-1" }, null, -1)]));
}]]), Oo = { xmlns: "http://www.w3.org/2000/svg", width: "1.5em", height: "1.5em", viewBox: "0 0 24 24" }, Po = $t({ name: "IcRoundLastPage" }, [["render", function(t, e, n, o, a, r) {
  return ft(), Ft("svg", Oo, e[0] || (e[0] = [St("path", { fill: "currentColor", d: "M6.29 8.11L10.18 12l-3.89 3.89A.996.996 0 1 0 7.7 17.3l4.59-4.59a.996.996 0 0 0 0-1.41L7.7 6.7a.996.996 0 0 0-1.41 0c-.38.39-.38 1.03 0 1.41M17 6c.55 0 1 .45 1 1v10c0 .55-.45 1-1 1s-1-.45-1-1V7c0-.55.45-1 1-1" }, null, -1)]));
}]]), Mo = { class: "mine-pro-table-col-setting" }, No = { class: "settings-list" }, Ro = { class: "label" }, Io = { class: "setting-fixed" }, ko = fe({ __name: "proTableSetting", props: { proxy: {} }, setup(t) {
  const e = ct();
  return en(() => {
    Ut(() => {
      e.value = t.proxy.getTableColumns();
    });
  }), (n, o) => {
    const a = V("el-button"), r = V("el-switch"), i = V("el-link"), c = V("el-dropdown-item"), u = V("el-dropdown-menu"), v = V("el-dropdown");
    return ft(), he(v, { "max-height": 350, "hide-on-click": !1, trigger: "click" }, { dropdown: Nt(() => [y(u, { class: $n(`mine-cols-setting${n.proxy.getCurrentId()}`) }, { default: Nt(() => [(ft(!0), Ft(Gt, null, Wn(e.value, (s, g) => (ft(), he(c, { key: g }, { default: Nt(() => [St("div", Mo, [St("div", No, [y(r, { modelValue: s.hide, "onUpdate:modelValue": (C) => s.hide = C, size: "small", "active-value": !1, "inactive-value": !0 }, null, 8, ["modelValue", "onUpdate:modelValue"]), St("div", Ro, Vn(En(xt)(s.label) ? s.label() : s.label ?? "unknown"), 1)]), St("div", Io, [y(i, { underline: "never", type: (s == null ? void 0 : s.fixed) === "left" ? "primary" : void 0, onClick: () => s.fixed = (s == null ? void 0 : s.fixed) !== "left" ? "left" : void 0 }, { default: Nt(() => [y(Co)]), _: 2 }, 1032, ["type", "onClick"]), y(i, { underline: "never", type: (s == null ? void 0 : s.fixed) === "right" ? "primary" : void 0, onClick: () => s.fixed = (s == null ? void 0 : s.fixed) !== "right" ? "right" : void 0 }, { default: Nt(() => [y(Po)]), _: 2 }, 1032, ["type", "onClick"])])])]), _: 2 }, 1024))), 128))]), _: 1 }, 8, ["class"])]), default: Nt(() => [y(a, { circle: "", style: { "margin-left": "12px" } }, { default: Nt(() => [y(_o)]), _: 1 })]), _: 1 });
  };
} }), Ao = [{ name: "mineProTableRefresh", render: () => mo, order: 1 }, { name: "mineProTableSearch", render: () => wo, order: 2 }, { name: "mineProTablePrint", render: () => Eo, order: 3 }, { name: "mineProTableSetting", render: () => ko, order: 4 }], Lo = { install(t, e) {
  t.component(Sn.name, Sn);
  const n = ct(e ?? { ssr: !1, provider: { app: t } });
  n.value.provider.renderPlugins = po, n.value.provider.toolbars = Ao, t.provide("MaProTableOptions", n);
} };
export {
  Lo as MaProTable,
  Lo as default,
  so as useProTableRenderPlugin,
  zo as useProTableToolbar
};
