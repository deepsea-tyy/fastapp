import { defineComponent as $, ref as h, inject as F, onMounted as H, watch as R, onBeforeUnmount as U, withDirectives as m, createVNode as i, resolveDirective as q, Fragment as k, mergeProps as x, vShow as G, isVNode as J, getCurrentInstance as K } from "vue";
import { ElLoadingDirective as Q, ElTable as W, ElEmpty as X, ElPagination as Y, ElTableColumn as Z } from "element-plus";
const D = $({ name: "MaTable", props: { options: { type: Object, default: () => ({}) }, columns: { type: Array, default: () => [] } }, directives: { Loading: Q }, emits: ["set-data-callback"], setup(r, { slots: a, attrs: p, emit: c, expose: y }) {
  const t = h(r.options), d = h(r.columns), N = F("MaTableOptions"), O = h(!1), T = h(), b = () => {
    const { adaptionOffsetBottom: e } = t.value, n = window.innerHeight - (e ?? 70);
    t.value.height = `${n}px`;
  }, w = h(1);
  H(async () => {
    O.value = !0;
  }), R(() => {
    var e;
    return (e = t.value) == null ? void 0 : e.adaption;
  }, (e) => {
    e && (window.addEventListener("resize", b), b());
  }, { immediate: !0 }), R(() => {
    var e;
    return (e = t.value) == null ? void 0 : e.adaptionOffsetBottom;
  }, () => {
    var e;
    (e = t.value) != null && e.adaption && b();
  }, { immediate: !0 }), U(() => {
    O.value = !1, window.removeEventListener("resize", b);
  });
  const V = () => {
    var n, o;
    const { pagination: e } = t.value;
    return m(i("div", { className: "ma-pagination" }, [i("div", { class: "ma-pagination-left" }, [(n = a == null ? void 0 : a.pageLeft) == null ? void 0 : n.call(a)]), (((o = t.value) == null ? void 0 : o.showPagination) ?? !1) && e && i("div", { class: "ma-el-page" }, [i(Y, x({ total: 0, onChange: () => {
    } }, e, { currentPage: w.value, "onUpdate:currentPage": (l) => w.value = l, size: (e == null ? void 0 : e.size) ?? "default", pagerCount: (e == null ? void 0 : e.pagerCount) ?? 5, layout: (e == null ? void 0 : e.layout) ?? "total, prev, pager, next, sizes, jumper" }), null)])]), [[G, a.pageLeft || e]]);
  }, j = (e, n) => {
    var M, A, B, z;
    if (e != null && e.hide && (e == null ? void 0 : e.hide) instanceof Function && e.hide(p) || e != null && e.hide && typeof (e == null ? void 0 : e.hide) == "boolean" && e.hide) return;
    const o = typeof e.prop == "function" ? e.prop(n) : e.prop;
    let l = { default: (s) => {
      var u, v, f;
      return ((u = e == null ? void 0 : e.cellRender) == null ? void 0 : u.call(e, Object.assign(s, { options: t.value, attrs: p }))) ?? ((v = a == null ? void 0 : a[`column-${o}`]) == null ? void 0 : v.call(a, s)) ?? ((f = a == null ? void 0 : a.default) == null ? void 0 : f.call(a, s));
    }, header: (s) => {
      var u, v, f;
      return ((u = e == null ? void 0 : e.headerRender) == null ? void 0 : u.call(e, Object.assign(s, { options: t.value, attrs: p }))) ?? ((v = a == null ? void 0 : a[`header-${o}`]) == null ? void 0 : v.call(a, s)) ?? ((f = a == null ? void 0 : a.header) == null ? void 0 : f.call(a, s));
    }, filterIcon: (s) => {
      var u;
      return (u = a == null ? void 0 : a.filterIcon) == null ? void 0 : u.call(a, s);
    } };
    const { label: C, prop: _, children: g, cellRender: ee, headerRender: ae, ...S } = e;
    return g && g.length > 0 && (l.default = () => g == null ? void 0 : g.map(j)), i(Z, x({ key: n }, S, { label: typeof C == "function" ? C() : C, prop: o, align: (e == null ? void 0 : e.align) ?? ((M = t.value) == null ? void 0 : M.columnAlign) ?? "center", headerAlign: (e == null ? void 0 : e.align) ?? ((A = t.value) == null ? void 0 : A.columnAlign) ?? (e == null ? void 0 : e.headerAlign) ?? ((B = t.value) == null ? void 0 : B.headerAlign) ?? "center", showOverflowTooltip: (e == null ? void 0 : e.showOverflowTooltip) ?? ((z = t.value) == null ? void 0 : z.showOverflowTooltip) ?? !0 }), typeof (L = l) == "function" || Object.prototype.toString.call(L) === "[object Object]" && !J(L) ? l : { default: () => [l] });
    var L;
  }, I = () => {
    const { on: e, pagination: n, ...o } = t.value;
    return i(k, null, [i(W, x({ ref: T }, e, o, p), { default: () => {
      var l;
      return [i(k, null, [(l = d.value) == null ? void 0 : l.map(j)])];
    }, append: () => {
      var l;
      return (l = a.append) == null ? void 0 : l.call(a);
    }, empty: () => {
      var l;
      return ((l = a.empty) == null ? void 0 : l.call(a)) ?? i(X, null, null);
    } }), V()]);
  }, P = () => {
    const { loading: e, loadingConfig: n, height: o, maxHeight: l } = t.value;
    return m(i("div", { className: "ma-table", "element-loading-svg": (n == null ? void 0 : n.svg) ?? '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 1024 1024"><path fill="currentColor" d="M512 64a32 32 0 0 1 32 32v192a32 32 0 0 1-64 0V96a32 32 0 0 1 32-32m0 640a32 32 0 0 1 32 32v192a32 32 0 1 1-64 0V736a32 32 0 0 1 32-32m448-192a32 32 0 0 1-32 32H736a32 32 0 1 1 0-64h192a32 32 0 0 1 32 32m-640 0a32 32 0 0 1-32 32H96a32 32 0 0 1 0-64h192a32 32 0 0 1 32 32M195.2 195.2a32 32 0 0 1 45.248 0L376.32 331.008a32 32 0 0 1-45.248 45.248L195.2 240.448a32 32 0 0 1 0-45.248m452.544 452.544a32 32 0 0 1 45.248 0L828.8 783.552a32 32 0 0 1-45.248 45.248L647.744 692.992a32 32 0 0 1 0-45.248M828.8 195.264a32 32 0 0 1 0 45.184L692.992 376.32a32 32 0 0 1-45.248-45.248l135.808-135.808a32 32 0 0 1 45.248 0m-452.544 452.48a32 32 0 0 1 0 45.248L240.448 828.8a32 32 0 0 1-45.248-45.248l135.808-135.808a32 32 0 0 1 45.248 0"/></svg>', "element-loading-svg-view-box": (n == null ? void 0 : n.viewBox) ?? "-9, -9, 50, 50", "element-loading-text": (n == null ? void 0 : n.text) ?? null, "element-loading-spinner": (n == null ? void 0 : n.spinner) ?? null, "element-loading-background": (n == null ? void 0 : n.spinner) ?? null, "element-loading-custom-class": (n == null ? void 0 : n.customClass) ?? null }, [I()]), [[q("loading"), e]]);
  }, E = (e) => d.value = e;
  return y({ setData: (e) => {
    t.value.data = e, c("set-data-callback", e);
  }, setPagination: (e) => {
    var n;
    return t.value.pagination = Object.assign(((n = t.value) == null ? void 0 : n.pagination) ?? {}, e);
  }, setCurrentPage: (e) => w.value = e, getCurrentPage: () => w.value, setLoadingState: (e) => t.value.loading = e, setOptions: (e) => t.value = Object.assign(t.value, e), getOptions: () => t.value, setColumns: E, getColumns: () => d.value, appendColumn: (e) => d.value.push(e), removeColumn: (e) => E(d.value.filter((n, o) => (typeof n.prop == "function" ? n.prop(o) : n.prop) !== e)), getColumnByProp: (e) => {
    var n;
    return ((n = d.value.filter((o, l) => (typeof o.prop == "function" ? o.prop(l) : o.prop) === e)) == null ? void 0 : n[0]) ?? null;
  }, getElTableRef: () => T.value }), () => N.ssr ? O.value && P() : P();
} });
function le(r) {
  return new Promise(async (a, p) => {
    const c = K();
    H(async () => {
      if (c && c.refs[r]) {
        const y = c.refs[r];
        a({ ...y });
      } else p("[@ma/table]: not found ref for ma-table component");
    });
  });
}
const oe = { install(r, a) {
  r.component(D.name, D), r.provide("MaTableOptions", a ?? { ssr: !1 });
} };
export {
  oe as MaTable,
  oe as default,
  le as useTable
};
