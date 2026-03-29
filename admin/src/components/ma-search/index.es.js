import { createElementBlock as b, openBlock as A, createElementVNode as O, defineComponent as ee, inject as ae, ref as w, getCurrentInstance as le, computed as Z, onMounted as se, nextTick as oe, onBeforeUnmount as ne, createVNode as t, Fragment as re, withDirectives as te, resolveComponent as q, mergeProps as E, vShow as ie } from "vue";
import { ElButton as J } from "element-plus";
const ue = { name: "HeroiconsMagnifyingGlass" }, _ = (i, l) => {
  const v = i.__vccOpts || i;
  for (const [p, f] of l) v[p] = f;
  return v;
}, ce = { xmlns: "http://www.w3.org/2000/svg", width: "1.2em", height: "1.2em", viewBox: "0 0 20 20" }, de = [O("path", { fill: "currentColor", fillRule: "evenodd", d: "M9 3.5a5.5 5.5 0 1 0 0 11a5.5 5.5 0 0 0 0-11M2 9a7 7 0 1 1 12.452 4.391l3.328 3.329a.75.75 0 1 1-1.06 1.06l-3.329-3.328A7 7 0 0 1 2 9", clipRule: "evenodd" }, null, -1)], pe = _(ue, [["render", function(i, l, v, p, f, x) {
  return A(), b("svg", ce, de);
}]]), ve = { name: "CarbonZoomReset" }, me = { xmlns: "http://www.w3.org/2000/svg", width: "1.2em", height: "1.2em", viewBox: "0 0 32 32" }, fe = [O("path", { fill: "currentColor", d: "M22.448 21A10.86 10.86 0 0 0 25 14A10.99 10.99 0 0 0 6 6.466V2H4v8h8V8H7.332a8.977 8.977 0 1 1-2.1 8h-2.04A11.01 11.01 0 0 0 14 25a10.86 10.86 0 0 0 7-2.552L28.586 30L30 28.586Z" }, null, -1)], he = _(ve, [["render", function(i, l, v, p, f, x) {
  return A(), b("svg", me, fe);
}]]), ge = { name: "MaterialSymbolsKeyboardArrowUp" }, we = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, xe = [O("path", { fill: "currentColor", d: "m12 10.8l-4.6 4.6L6 14l6-6l6 6l-1.4 1.4z" }, null, -1)], ye = _(ge, [["render", function(i, l, v, p, f, x) {
  return A(), b("svg", we, xe);
}]]), Se = { name: "MaterialSymbolsKeyboardArrowDown" }, Me = { xmlns: "http://www.w3.org/2000/svg", width: "1.3em", height: "1.3em", viewBox: "0 0 24 24" }, Be = [O("path", { fill: "currentColor", d: "m12 15.4l-6-6L7.4 8l4.6 4.6L16.6 8L18 9.4z" }, null, -1)], be = _(Se, [["render", function(i, l, v, p, f, x) {
  return A(), b("svg", Me, Be);
}]]), Q = ee({ name: "MaSearch", props: { options: { type: Object, default: () => ({}) }, formOptions: { type: Object, default: () => ({}) }, searchItems: { type: Array, default: () => [] } }, emits: ["search", "reset", "fold"], setup(i, { slots: l, attrs: v, emit: p, expose: f }) {
  var K;
  const x = ae("MaSearchOptions"), R = w(!1), P = `_${Math.floor(1e5 * Math.random() + 2e4 * Math.random() + 5e3 * Math.random())}`, C = le(), s = w(i.options), M = w(i.formOptions), u = w(i.searchItems), c = w(((K = s.value) == null ? void 0 : K.defaultValue) ?? {}), B = () => {
    var e;
    return (e = C == null ? void 0 : C.proxy) == null ? void 0 : e.$refs[`maFormSearchRef${P}`];
  }, N = () => {
    delete c.value.__MaSearchAction, p("search", c.value);
  }, F = () => s.value.fold, $ = () => {
    s.value.fold = !s.value.fold;
    const e = s.value.foldRows;
    u.value.map((a, r) => {
      var o;
      if (r > (e ? e - 1 : 1) && a.prop !== "__MaSearchAction") {
        const n = typeof a.hide == "function" ? (o = a == null ? void 0 : a.hide) == null ? void 0 : o.call(a) : (a == null ? void 0 : a.hide) ?? !1;
        a.show = !n && s.value.fold, u.value[r] = a;
      }
    }), p("fold", s.value.fold);
  }, X = () => {
    var o, n;
    const { text: e } = s.value, a = F() ? ((o = e == null ? void 0 : e.isFoldBtn) == null ? void 0 : o.call(e)) ?? "折叠" : ((n = e == null ? void 0 : e.notFoldBtn) == null ? void 0 : n.call(e)) ?? "展开", r = F() ? t(ye, null, null) : t(be, null, null);
    return t(q("el-link"), { type: "primary", underline: "never", onClick: () => $() }, { default: () => a, icon: () => t("div", { className: "fold-icon" }, [r]) });
  }, k = () => {
    var n, T, U, G;
    const { text: e, foldButtonShow: a, searchBtnProps: r, resetBtnProps: o } = s.value;
    return t("div", { className: "ma-list-search-action" }, [((n = l.actions) == null ? void 0 : n.call(l)) ?? t("div", { className: "search-actions" }, [t("div", { className: "actions-first" }, [(T = l.beforeActions) == null ? void 0 : T.call(l)]), t(J, E({ type: "primary", plain: !0 }, r, { onClick: () => N() }), { default: () => {
      var m;
      return ((m = e == null ? void 0 : e.searchBtn) == null ? void 0 : m.call(e)) ?? "搜索";
    }, icon: () => t(pe, null, null) }), t(J, E(o, { onClick: () => {
      var m, D;
      return u.value.map((d, Ae) => {
        var W;
        const S = typeof d.prop == "function" ? (W = d == null ? void 0 : d.prop) == null ? void 0 : W.call(d) : d.prop ?? void 0;
        if (!(d != null && d.show) && S && S !== "__MaSearchAction") if (S.indexOf(".") !== -1) {
          const [Y] = S.split(".");
          c.value[Y] = void 0;
        } else c.value[S] = void 0;
      }), (D = (m = B()) == null ? void 0 : m.getElFormRef()) == null || D.resetFields(), delete c.value.__MaSearchAction, void p("reset", c.value);
    } }), { default: () => {
      var m;
      return ((m = e == null ? void 0 : e.resetBtn) == null ? void 0 : m.call(e)) ?? "重置";
    }, icon: () => t(he, null, null) }), t("div", { className: "actions-end" }, [(U = l.afterActions) == null ? void 0 : U.call(l)])]), (a ?? !0) && ((G = u.value) == null ? void 0 : G.length) > 2 && X()]);
  }, h = Z(() => {
    const { cols: e } = s.value;
    switch (g.value) {
      case "xl":
        return (e == null ? void 0 : e.xl) ?? 4;
      case "lg":
        return (e == null ? void 0 : e.lg) ?? 3;
      case "md":
        return (e == null ? void 0 : e.md) ?? 2;
      case "sm":
        return (e == null ? void 0 : e.sm) ?? 2;
      case "xs":
        return (e == null ? void 0 : e.xs) ?? 1;
    }
  });
  Z(() => ({ display: "grid", gridGap: "10px 0px", gridTemplateColumns: `repeat(${h.value}, minmax(0, 1fr))` }));
  const L = (e, a = 1, r = 0) => {
    let o = a, n = r;
    return e ? { gridColumnStart: h.value - o - n + 1, gridColumnEnd: `span ${o + n}`, marginLeft: n !== 0 ? `calc(((100% + 10px) / ${o + n}) * ${n})` : "unset" } : { gridColumn: `span ${o + n > h.value ? h.value : o + n}/span ${o + n > h.value ? h.value : o + n}`, marginLeft: n !== 0 ? `calc(((100% + 10px) / ${o + n}) * ${n})` : "unset" };
  }, y = () => {
    var e;
    H("__MaSearchAction") || u.value.push({ prop: "__MaSearchAction", render: () => k }), u.value.map((a, r) => {
      a.prop !== "__MaSearchAction" ? (a.renderProps === void 0 ? a.renderProps = { class: "mine-w-full" } : a.renderProps.class = "mine-w-full", a.renderProps.onKeyup = (o) => {
        (o == null ? void 0 : o.code) !== "Enter" && (o == null ? void 0 : o.key) !== "Enter" || N();
      }, a.cols === void 0 ? a.cols = { style: L(!1, a == null ? void 0 : a.span, a == null ? void 0 : a.offset) } : a.cols.style = L(!1, a == null ? void 0 : a.span, a == null ? void 0 : a.offset)) : (a.itemProps = { labelWidth: "0px" }, a.cols = { style: L(!0, 1) }), u.value[r] = a;
    }), M.value.flex = { style: { display: "grid" } }, (e = B()) == null || e.setItems(u.value);
  }, I = () => {
    var e;
    (e = B()) == null || e.setOptions(M.value);
  }, V = () => {
    y(), I();
    const { show: e } = s.value, a = typeof e == "function" ? e : () => e !== !1;
    return t(re, null, [te(t("div", { className: `ma-list-search-panel sp-${P}` }, [t(q("ma-form"), E({ ref: `maFormSearchRef${P}`, modelValue: c.value, "onUpdate:modelValue": (r) => c.value = r }, v), { default: l != null && l.default ? () => {
      var r;
      return (r = l.default) == null ? void 0 : r.call(l);
    } : null })]), [[ie, a()]])]);
  }, g = w(), j = () => {
    let e = window.innerWidth;
    switch (!!e) {
      case e < 768:
        g.value = "xs";
        break;
      case (e >= 768 && e < 992):
        g.value = "sm";
        break;
      case (e >= 992 && e < 1200):
        g.value = "md";
        break;
      case (e >= 1200 && e < 1920):
        g.value = "lg";
        break;
      case e >= 1920:
        g.value = "xl";
    }
  };
  se(async () => {
    var e;
    R.value = !0, s.value.fold = ((e = s.value) == null ? void 0 : e.fold) ?? !1, await oe(() => $()), j(), window.addEventListener("resize", j);
  }), ne(() => {
    window.removeEventListener("resize", j);
  });
  const z = (e) => {
    u.value = e, y();
  }, H = (e) => {
    var a;
    return ((a = u.value.filter((r) => r.prop === e)) == null ? void 0 : a[0]) ?? null;
  };
  return f({ getMaFormRef: B, setSearchForm: (e) => {
    c.value = e === null ? {} : Object.assign(c.value, e);
  }, getSearchForm: () => (delete c.value.__MaSearchAction, c.value), foldToggle: $, getFold: F, setShowState: (e) => s.value.show = e, getShowState: () => {
    var e;
    return ((e = s.value) == null ? void 0 : e.show) ?? !0;
  }, setOptions: (e) => {
    s.value = Object.assign(s.value, e), y(), I();
  }, getOptions: () => s.value, setFormOptions: (e) => {
    M.value = Object.assign(s.value, e), I();
  }, getFormOptions: () => M.value, setItems: z, getItems: () => u.value, appendItem: (e) => {
    u.value.push(e), y();
  }, removeItem: (e) => {
    z(u.value.filter((a) => a.prop !== e)), y();
  }, getItemByProp: H, setSearchBtnProps: (e) => {
    s.value.searchBtnProps = Object.assign(s.value.searchBtnProps ?? {}, e), k();
  }, setResetBtnProps: (e) => {
    s.value.resetBtnProps = Object.assign(s.value.resetBtnProps ?? {}, e), k();
  } }), () => x.ssr ? R.value && V() : V();
} }), Pe = { install(i, l) {
  i.component(Q.name, Q), i.provide("MaSearchOptions", l ?? { ssr: !1 });
} };
export {
  Pe as MaSearch,
  Pe as default
};
