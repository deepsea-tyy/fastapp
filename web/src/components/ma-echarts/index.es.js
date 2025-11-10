import { isRef as y, unref as b, getCurrentInstance as D, shallowRef as k, onMounted as z, onActivated as L, nextTick as O, watchEffect as T } from "vue";
const w = () => {
};
function x(...i) {
  let o, c, r, t, u, l, e = 0, n = !0, a = w;
  y(i[0]) || typeof i[0] != "object" ? [r, t = !0, u = !0, l = !1] = i : { delay: r, trailing: t = !0, leading: u = !0, rejectOnCancel: l = !1 } = i[0];
  const v = () => {
    o && (clearTimeout(o), o = void 0, a(), a = w);
  };
  return (d) => {
    const s = typeof (p = r) == "function" ? p() : b(p);
    var p;
    const g = Date.now() - e, f = () => c = d();
    return v(), s <= 0 ? (e = Date.now(), f()) : (g > s && (u || !n) ? (e = Date.now(), f()) : t && (c = new Promise((h, m) => {
      a = l ? m : h, o = setTimeout(() => {
        e = Date.now(), n = !0, h(f()), v();
      }, Math.max(0, s - g));
    })), u || o || (o = setTimeout(() => n = !0, s)), n = !1, c);
  };
}
function P(i, o = 200, c = !1, r = !0, t = !1) {
  return /* @__PURE__ */ function(u, l) {
    return function(...e) {
      return new Promise((n, a) => {
        Promise.resolve(u(() => l.apply(this, e), { fn: l, thisArg: this, args: e })).then(n).catch(a);
      });
    };
  }(x(o, c, r, t), i);
}
function C(i, o) {
  const { appContext: c } = D(), r = c.config.globalProperties.$echarts;
  if (!r) return null;
  const t = k(null), u = () => t.value && t.value.resize(), l = P(() => {
    u();
  }, 100);
  return z(async () => {
    await (async () => {
      await O(), i.value && (t.value = r.init(i.value, (o == null ? void 0 : o.theme) ?? "default", o));
    })(), window.addEventListener("resize", l), await l();
  }), L(async () => await l()), { echarts: r, getInstance: () => t.value, setOption: (e, n) => {
    T(() => {
      t.value && t.value.setOption(e), n && (n == null ? void 0 : n.length) > 0 && t.value && n.map((a) => {
        var v, d;
        (a == null ? void 0 : a.type) !== "zrender" && typeof (a == null ? void 0 : a.callback) == "function" && ((v = t.value) == null || v.on(a == null ? void 0 : a.name, (a == null ? void 0 : a.query) ?? "", (s) => {
          a == null || a.callback(s);
        })), (a == null ? void 0 : a.type) === "zrender" && typeof (a == null ? void 0 : a.callback) == "function" && ((d = t.value) == null || d.getZr().on(a == null ? void 0 : a.name, (s) => {
          s.target || (a == null || a.callback(s));
        }));
      });
    });
  }, showLoading: (e) => {
    const n = (e == null ? void 0 : e.type) ?? "default", a = (e == null ? void 0 : e.opts) ?? {};
    t.value && t.value.showLoading(n, a);
  }, hideLoading: () => t.value && t.value.hideLoading(), clear: () => {
    var e;
    t.value && (t.value.dispose(), t.value.clear(), window.removeEventListener("resize", l), t.value = null, (e = i.value) == null || e.remove());
  }, resize: u, appendData: (e) => {
    t.value && t.value.appendData(e);
  }, getDom: () => {
    var e;
    return ((e = t.value) == null ? void 0 : e.getDom()) ?? void 0;
  }, getWidth: () => {
    var e;
    return ((e = t.value) == null ? void 0 : e.getWidth()) ?? void 0;
  }, getHeight: () => {
    var e;
    return ((e = t == null ? void 0 : t.value) == null ? void 0 : e.getHeight()) ?? void 0;
  }, getOption: () => t.value && t.value.getOption() };
}
export {
  C as default
};
