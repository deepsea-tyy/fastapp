import { defineComponent as $, ref as h, inject as F, onMounted as H, watch as z, onBeforeUnmount as U, withDirectives as R, createVNode as i, resolveDirective as q, Fragment as k, mergeProps as x, vShow as G, isVNode as J, getCurrentInstance as K } from "vue";
import { ElLoadingDirective as Q, ElTable as W, ElEmpty as X, ElPagination as Y, ElTableColumn as Z } from "element-plus";
const D = $({ name: "MaTable", props: { options: { type: Object, default: () => ({}) }, columns: { type: Array, default: () => [] } }, directives: { Loading: Q }, emits: ["set-data-callback"], setup(r, { slots: e, attrs: p, emit: m, expose: w }) {
  const t = h(r.options), d = h(r.columns), N = F("MaTableOptions"), y = h(!1), T = h(), b = () => {
    const { adaptionOffsetBottom: a } = t.value, n = window.innerHeight - (a ?? 70);
    t.value.height = `${n}px`;
  }, O = h(1);
  H(async () => {
    y.value = !0;
  }), z(() => {
    var a;
    return (a = t.value) == null ? void 0 : a.adaption;
  }, (a) => {
    a && (window.addEventListener("resize", b), b());
  }, { immediate: !0 }), z(() => {
    var a;
    return (a = t.value) == null ? void 0 : a.adaptionOffsetBottom;
  }, () => {
    var a;
    (a = t.value) != null && a.adaption && b();
  }, { immediate: !0 }), U(() => {
    y.value = !1, window.removeEventListener("resize", b);
  });
  const V = () => {
    var n, o;
    const { pagination: a } = t.value;
    return R(i("div", { className: "base.pagination" }, [i("div", { class: "base.pagination-left" }, [(n = e == null ? void 0 : e.pageLeft) == null ? void 0 : n.call(e)]), (((o = t.value) == null ? void 0 : o.showPagination) ?? !1) && a && i("div", { class: "base.el-page" }, [i(Y, x({ total: 0, onChange: () => {
    } }, a, { currentPage: O.value, "onUpdate:currentPage": (l) => O.value = l, size: (a == null ? void 0 : a.size) ?? "default", pagerCount: (a == null ? void 0 : a.pagerCount) ?? 5, layout: (a == null ? void 0 : a.layout) ?? "total, prev, pager, next, sizes, jumper" }), null)])]), [[G, e.pageLeft || a]]);
  }, j = (a, n) => {
    var M, A, B, c;
    if (a != null && a.hide && (a == null ? void 0 : a.hide) instanceof Function && a.hide(p) || a != null && a.hide && typeof (a == null ? void 0 : a.hide) == "boolean" && a.hide) return;
    const o = typeof a.prop == "function" ? a.prop(n) : a.prop;
    let l = { default: (s) => {
      var u, g, f;
      return ((u = a == null ? void 0 : a.cellRender) == null ? void 0 : u.call(a, Object.assign(s, { options: t.value, attrs: p }))) ?? ((g = e == null ? void 0 : e[`column-${o}`]) == null ? void 0 : g.call(e, s)) ?? ((f = e == null ? void 0 : e.default) == null ? void 0 : f.call(e, s));
    }, header: (s) => {
      var u, g, f;
      return ((u = a == null ? void 0 : a.headerRender) == null ? void 0 : u.call(a, Object.assign(s, { options: t.value, attrs: p }))) ?? ((g = e == null ? void 0 : e[`header-${o}`]) == null ? void 0 : g.call(e, s)) ?? ((f = e == null ? void 0 : e.header) == null ? void 0 : f.call(e, s));
    }, filterIcon: (s) => {
      var u;
      return (u = e == null ? void 0 : e.filterIcon) == null ? void 0 : u.call(e, s);
    } };
    const { label: C, prop: _, children: v, cellRender: aa, headerRender: ea, ...S } = a;
    return v && v.length > 0 && (l.default = () => v == null ? void 0 : v.map(j)), i(Z, x({ key: n }, S, { label: typeof C == "function" ? C() : C, prop: o, align: (a == null ? void 0 : a.align) ?? ((M = t.value) == null ? void 0 : M.columnAlign) ?? "center", headerAlign: (a == null ? void 0 : a.align) ?? ((A = t.value) == null ? void 0 : A.columnAlign) ?? (a == null ? void 0 : a.headerAlign) ?? ((B = t.value) == null ? void 0 : B.headerAlign) ?? "center", showOverflowTooltip: (a == null ? void 0 : a.showOverflowTooltip) ?? ((c = t.value) == null ? void 0 : c.showOverflowTooltip) ?? !0 }), typeof (L = l) == "function" || Object.prototype.toString.call(L) === "[object Object]" && !J(L) ? l : { default: () => [l] });
    var L;
  }, I = () => {
    const { on: a, pagination: n, ...o } = t.value;
    return i(k, null, [i(W, x({ ref: T }, a, o, p), { default: () => {
      var l;
      return [i(k, null, [(l = d.value) == null ? void 0 : l.map(j)])];
    }, append: () => {
      var l;
      return (l = e.append) == null ? void 0 : l.call(e);
    }, empty: () => {
      var l;
      return ((l = e.empty) == null ? void 0 : l.call(e)) ?? i(X, null, null);
    } }), V()]);
  }, P = () => {
    const { loading: a, loadingConfig: n, height: o, maxHeight: l } = t.value;
    return R(i("div", { className: "base.table", "element-loading-svg": (n == null ? void 0 : n.svg) ?? '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 1024 1024"><path fill="currentColor" d="M512 64a32 32 0 0 1 32 32v192a32 32 0 0 1-64 0V96a32 32 0 0 1 32-32m0 640a32 32 0 0 1 32 32v192a32 32 0 1 1-64 0V736a32 32 0 0 1 32-32m448-192a32 32 0 0 1-32 32H736a32 32 0 1 1 0-64h192a32 32 0 0 1 32 32m-640 0a32 32 0 0 1-32 32H96a32 32 0 0 1 0-64h192a32 32 0 0 1 32 32M195.2 195.2a32 32 0 0 1 45.248 0L376.32 331.008a32 32 0 0 1-45.248 45.248L195.2 240.448a32 32 0 0 1 0-45.248m452.544 452.544a32 32 0 0 1 45.248 0L828.8 783.552a32 32 0 0 1-45.248 45.248L647.744 692.992a32 32 0 0 1 0-45.248M828.8 195.264a32 32 0 0 1 0 45.184L692.992 376.32a32 32 0 0 1-45.248-45.248l135.808-135.808a32 32 0 0 1 45.248 0m-452.544 452.48a32 32 0 0 1 0 45.248L240.448 828.8a32 32 0 0 1-45.248-45.248l135.808-135.808a32 32 0 0 1 45.248 0"/></svg>', "element-loading-svg-view-box": (n == null ? void 0 : n.viewBox) ?? "-9, -9, 50, 50", "element-loading-text": (n == null ? void 0 : n.text) ?? null, "element-loading-spinner": (n == null ? void 0 : n.spinner) ?? null, "element-loading-background": (n == null ? void 0 : n.spinner) ?? null, "element-loading-custom-class": (n == null ? void 0 : n.customClass) ?? null }, [I()]), [[q("loading"), a]]);
  }, E = (a) => d.value = a;
  return w({ setData: (a) => {
    t.value.data = a, m("set-data-callback", a);
  }, setPagination: (a) => {
    var n;
    return t.value.pagination = Object.assign(((n = t.value) == null ? void 0 : n.pagination) ?? {}, a);
  }, setCurrentPage: (a) => O.value = a, setLoadingState: (a) => t.value.loading = a, setOptions: (a) => t.value = Object.assign(t.value, a), getOptions: () => t.value, setColumns: E, getColumns: () => d.value, appendColumn: (a) => d.value.push(a), removeColumn: (a) => E(d.value.filter((n, o) => (typeof n.prop == "function" ? n.prop(o) : n.prop) !== a)), getColumnByProp: (a) => {
    var n;
    return ((n = d.value.filter((o, l) => (typeof o.prop == "function" ? o.prop(l) : o.prop) === a)) == null ? void 0 : n[0]) ?? null;
  }, getElTableRef: () => T.value }), () => N.ssr ? y.value && P() : P();
} });
function la(r) {
  return new Promise(async (e, p) => {
    const m = K();
    H(async () => {
      if (m && m.refs[r]) {
        const w = m.refs[r];
        e({ ...w });
      } else p("[@base.table]: not found ref for ma-table component");
    });
  });
}
const oa = { install(r, e) {
  r.component(D.name, D), r.provide("MaTableOptions", e ?? { ssr: !1 });
} };
export {
  oa as MaTable,
  oa as default,
  la as useTable
};
