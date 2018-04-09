var APP_VERSION = '1.0.21';
!function e(t, n, r) {
    function i(a, l) {
        if (!n[a]) {
            if (!t[a]) {
                var s = "function" == typeof require && require;
                if (!l && s)
                    return s(a, !0);
                if (o)
                    return o(a, !0);
                var c = new Error("Cannot find module '" + a + "'");
                throw c.code = "MODULE_NOT_FOUND", c
            }
            var u = n[a] = {
                exports: {}
            };
            t[a][0].call(u.exports, function(e) {
                var n = t[a][1][e];
                return i(n || e)
            }, u, u.exports, e, t, n, r)
        }
        return n[a].exports
    }
    for (var o = "function" == typeof require && require, a = 0; a < r.length; a++)
        i(r[a]);
    return i
}({
    1: [function(e, t, n) {
        "use strict";
        function r(e, t) {
            return u(d(e, t))
        }
        function i() {
            o(), a()
        }
        function o() {
            var e = r(".PassionPoints div.Feature"),
                t = e.length;
            t > 1 ? e.each(function(e) {
                var t = document.createElement("div");
                t.className = "toggle-feature-btn", t.setAttribute("aria-expanded", !1), e.appendChild(t), s(r(e), !1)
            }) : 1 === t && e.addClass("FeatureSingle")
        }
        function a() {
            var e = r(".PassionPoints div.Feature");
            e.length > 1 && e.each(function(e) {
                e.addEventListener("click", function(e) {
                    var t = r(e.target);
                    t.hasClass("toggle-feature-btn") && (t = r(t[0].parentElement)), s(t, !0)
                })
            })
        }
        function l(e, t, n) {
            if (t = Math.round(t), (n = Math.round(n)) < 0)
                return Promise.reject("bad duration");
            if (0 === n)
                return e.scrollTop = t, Promise.resolve();
            var r = Date.now(),
                i = r + n,
                o = e.scrollTop,
                a = t - o,
                l = function(e, t, n) {
                    if (n <= e)
                        return 0;
                    if (n >= t)
                        return 1;
                    var r = (n - e) / (t - e);
                    return r * r * (3 - 2 * r)
                };
            return new Promise(function(t, n) {
                var s = e.scrollTop,
                    c = function n() {
                        var c = Date.now(),
                            u = l(r, i, c),
                            d = Math.round(o + a * u);
                        return e.scrollTop = d, c >= i ? void t() : e.scrollTop === s && e.scrollTop !== d ? void t() : (s = e.scrollTop, void setTimeout(n, 0))
                    };
                setTimeout(c, 0)
            })
        }
        function s(e, t, n) {
            var i = r(e),
                o = (r(".PassionPoints .Feature"), r(".PassionPoints .Feature[aria-expanded=true]")),
                a = r(".FeatureBody", i),
                c = r(".toggle-feature-btn", i),
                u = void 0 !== n ? !n : "true" === i.attr("aria-expanded"),
                d = a[0].scrollHeight,
                T = .75 * d,
                _ = 0,
                p = !1;
            if (!u && n && o.length) {
                var f = r(".FeatureBody", o);
                _ = f.offset().height, p = f.offset().top < a.offset().top, s(o, !0, !1)
            }
            if (!u) {
                var O = i.offset().top,
                    $ = (document.body.scrollTop, Math.round(O - (p ? _ - c[0].scrollHeight : 0)));
                l(document.body, $, T)
            }
            a.css("max-height", d), c.attr("aria-expanded", !u);
            var h = function() {
                a.css("transition", "max-height " + T + "ms ease-in-out"), a.addClass("animating").attr("aria-hidden", u), i.attr("aria-expanded", !u)
            };
            t ? requestAnimationFrame(h) : h(), setTimeout(function() {
                a.removeClass("animating"), a.css("max-height", "unset")
            }, T);
            var L = new CustomEvent("passionPointTrigger", {
                detail: {
                    passionPointID: i.attr("id"),
                    state: u ? "collapsed" : "expanded"
                }
            });
            t && document.dispatchEvent(L)
        }
        function c(e) {
            s(e, !0, !0)
        }
        var u = e("bonzo"),
            d = e("qwery");
        t.exports = {
            init: i,
            decorate: o,
            attachEvents: a,
            openAPDPassionPoint: c
        }
    }, {
        bonzo: 4,
        qwery: 25
    }],
    2: [function(e, t, n) {
        "use strict";
        function r(e, t) {
            return d(T(e, t))
        }
        function i() {
            o(), a(), l()
        }
        function o() {
            var e = r(".AppleTopic div.Task > .Name"),
                t = e.length;
            if (t > 1) {
                r(".AppleTopic .Task > .Name");
                e.append('<span class="task-arrow"></span>'), e.each(function(e) {
                    var t = r(e),
                        n = t.attr("aria-controls");
                    t.replaceWith('<h2 class="Name"><button class="TaskButtonName" aria-controls="' + n + '">' + t.html() + "</button></h2>")
                });
                r(".TaskButtonName").each(function(e) {
                    var t = r(e),
                        n = t.parent().parent().attr("id"),
                        i = !1;
                    try {
                        i = "true" === window.sessionStorage.getItem(n + "-is-expanded")
                    } catch (e) {}
                    n != location.hash.split("#")[1] && c(t, !1, i)
                })
            } else
                1 === t && r(".AppleTopic div.Task").addClass("SoloTask")
        }
        function a() {
            r(".AppleTopic .Task > .Name").each(function(e) {
                e.addEventListener("click", s)
            }), window.onhashchange = l
        }
        function l() {
            var e = location.hash;
            if (e) {
                var t = e.split("#")[1],
                    n = r(".TaskButtonName[aria-controls*='" + t + "']");
                n && u(n)
            }
        }
        function s(e) {
            var t = r(e.target),
                n = void 0;
            t.hasClass("task-arrow") && (t = r(t.get(0).parentElement)), "H2" === t[0].tagName && (t = r(t.get(0).children[0])), e.altKey && (n = "false" === t.attr("aria-expanded"), t = r(".TaskButtonName")), t.each(function(e) {
                c(r(e), !0, n)
            })
        }
        function c(e, t, n) {
            var i = r(e),
                o = i.attr("aria-controls"),
                a = r("#" + o),
                l = void 0 !== n ? !n : "true" === i.attr("aria-expanded");
            l || a.css("display", "block");
            var s = a[0].scrollHeight,
                c = .75 * s;
            a.css("max-height", s);
            var u = function() {
                t && (a.css("transition", "max-height " + c + "ms ease-in-out, opacity 200ms " + c / 2 + "ms ease-in-out"), a.addClass("animating")), a.attr("aria-hidden", l), i.attr("aria-expanded", !l)
            };
            t ? requestAnimationFrame(u) : u(), setTimeout(function() {
                a.removeClass("animating"), a.css("max-height", "unset"), l && a.css("display", "none")
            }, c);
            var d = i.parent().parent().attr("id"),
                T = d + "-is-expanded";
            if (l)
                try {
                    window.sessionStorage.removeItem(T)
                } catch (e) {}
            else
                window.sessionStorage.setItem(T, "true");
            var _ = new CustomEvent("taskTrigger", {
                detail: {
                    taskBodyID: o,
                    state: l ? "collapsed" : "expanded"
                }
            });
            t && document.dispatchEvent(_)
        }
        function u(e) {
            c(e, !0, !0)
        }
        var d = e("bonzo"),
            T = e("qwery");
        t.exports = {
            init: i,
            decorate: o,
            attachEvents: a,
            openAPDSchemaTask: u
        }
    }, {
        bonzo: 4,
        qwery: 25
    }],
    3: [function(e, t, n) {
        "use strict";
        var r = function(e, t, n) {
                return a(e, n)[t] || ""
            },
            i = function(e, t) {
                var n = t || o(),
                    r = e[n];
                return r || (r = e[n.substr(0, 2)]), r || (console.warn("Could not find translations " + n), r = e.en), r
            },
            o = function() {
                var e = navigator.browserLanguage || navigator.systemLanguage || navigator.userLanguage || navigator.language;
                return e = e ? e.toLowerCase().replace("_", "-") : "en"
            },
            a = function(e, t) {
                return i(e, t)
            },
            l = o();
        t.exports = {
            get: r,
            currentLocale: l,
            currentStrings: a
        }
    }, {}],
    4: [function(e, t, n) {
        /*!
  * Bonzo: DOM Utility (c) Dustin Diaz 2012
  * https://github.com/ded/bonzo
  * License MIT
  */
        !function(e, n, r) {
            void 0 !== t && t.exports ? t.exports = r() : "function" == typeof define && define.amd ? define(r) : n.bonzo = r()
        }(0, this, function() {
            function e(e, t) {
                var n = null,
                    r = H.defaultView.getComputedStyle(e, "");
                return r && (n = r[t]), e.style[t] || n
            }
            function t(e) {
                return e && e.nodeName && (1 == e.nodeType || 11 == e.nodeType)
            }
            function n(e, n, r) {
                var i,
                    o,
                    a;
                if ("string" == typeof e)
                    return A.create(e);
                if (t(e) && (e = [e]), r) {
                    for (a = [], i = 0, o = e.length; i < o; i++)
                        a[i] = h(n, e[i]);
                    return a
                }
                return e
            }
            function r(e) {
                return new RegExp("(^|\\s+)" + e + "(\\s+|$)")
            }
            function i(e, t, n, r) {
                for (var i, o = 0, a = e.length; o < a; o++)
                    i = r ? e.length - o - 1 : o, t.call(n || e[i], e[i], i, e);
                return e
            }
            function o(e, n, r) {
                for (var i = 0, a = e.length; i < a; i++)
                    t(e[i]) && (o(e[i].childNodes, n, r), n.call(r || e[i], e[i], i, e));
                return e
            }
            function a(e) {
                return e.replace(/-(.)/g, function(e, t) {
                    return t.toUpperCase()
                })
            }
            function l(e) {
                return e ? e.replace(/([a-z])([A-Z])/g, "$1-$2").toLowerCase() : e
            }
            function s(e) {
                e[j]("data-node-uid") || e[M]("data-node-uid", ++x);
                var t = e[j]("data-node-uid");
                return U[t] || (U[t] = {})
            }
            function c(e) {
                var t = e[j]("data-node-uid");
                t && delete U[t]
            }
            function u(e) {
                var t;
                try {
                    return null === e || void 0 === e ? void 0 : "true" === e || "false" !== e && ("null" === e ? null : (t = parseFloat(e)) == e ? t : e)
                } catch (e) {}
            }
            function d(e, t, n) {
                for (var r = 0, i = e.length; r < i; ++r)
                    if (t.call(n || null, e[r], r, e))
                        return !0;
                return !1
            }
            function T(e) {
                return "transform" == e && (e = F.transform) || /^transform-?[Oo]rigin$/.test(e) && (e = F.transform + "Origin"), e ? a(e) : null
            }
            function _(e, t, r, o) {
                var a = 0,
                    l = t || this,
                    s = [];
                return i(n(z && "string" == typeof e && "<" != e.charAt(0) ? z(e) : e), function(e, t) {
                    i(l, function(n) {
                        r(e, s[a++] = t > 0 ? h(l, n) : n)
                    }, null, o)
                }, this, o), l.length = a, i(s, function(e) {
                    l[--a] = e
                }, null, !o), l
            }
            function p(e, t, n) {
                var r = A(e),
                    i = r.css("position"),
                    o = r.offset(),
                    a = "relative",
                    l = i == a,
                    s = [parseInt(r.css("left"), 10), parseInt(r.css("top"), 10)];
                "static" == i && (r.css("position", a), i = a), isNaN(s[0]) && (s[0] = l ? 0 : e.offsetLeft), isNaN(s[1]) && (s[1] = l ? 0 : e.offsetTop), null != t && (e.style.left = t - o.left + s[0] + W), null != n && (e.style.top = n - o.top + s[1] + W)
            }
            function f(e, t) {
                return "function" == typeof t ? t.call(e, e) : t
            }
            function O(e, t, n) {
                var r = this[0];
                return r ? null == e && null == t ? (L(r) ? E() : {
                    x: r.scrollLeft,
                    y: r.scrollTop
                })[n] : (L(r) ? C.scrollTo(e, t) : (null != e && (r.scrollLeft = e), null != t && (r.scrollTop = t)), this) : this
            }
            function $(e) {
                if (this.length = 0, e) {
                    e = "string" == typeof e || e.nodeType || void 0 === e.length ? [e] : e, this.length = e.length;
                    for (var t = 0; t < e.length; t++)
                        this[t] = e[t]
                }
            }
            function h(e, t) {
                var n,
                    r,
                    i,
                    o = t.cloneNode(!0);
                if (e.$ && "function" == typeof e.cloneEvents)
                    for (e.$(o).cloneEvents(t), n = e.$(o).find("*"), r = e.$(t).find("*"), i = 0; i < r.length; i++)
                        e.$(n[i]).cloneEvents(r[i]);
                return o
            }
            function L(e) {
                return e === C || /^(?:body|html)$/i.test(e.tagName)
            }
            function E() {
                return {
                    x: C.pageXOffset || g.scrollLeft,
                    y: C.pageYOffset || g.scrollTop
                }
            }
            function N(e) {
                var t = document.createElement("script"),
                    n = e.match(P);
                return t.src = n[1], t
            }
            function A(e) {
                return new $(e)
            }
            var m,
                B,
                I,
                C = window,
                H = C.document,
                g = H.documentElement,
                v = /^(checked|value|selected|disabled)$/i,
                b = /^(select|fieldset|table|tbody|tfoot|td|tr|colgroup)$/i,
                P = /\s*<script +src=['"]([^'"]+)['"]>/,
                S = ["<table>", "</table>", 1],
                y = ["<table><tbody><tr>", "</tr></tbody></table>", 3],
                D = ["<select>", "</select>", 1],
                w = ["_", "", 0, 1],
                R = {
                    thead: S,
                    tbody: S,
                    tfoot: S,
                    colgroup: S,
                    caption: S,
                    tr: ["<table><tbody>", "</tbody></table>", 2],
                    th: y,
                    td: y,
                    col: ["<table><colgroup>", "</colgroup></table>", 2],
                    fieldset: ["<form>", "</form>", 1],
                    legend: ["<form><fieldset>", "</fieldset></form>", 2],
                    option: D,
                    optgroup: D,
                    script: w,
                    style: w,
                    link: w,
                    param: w,
                    base: w
                },
                k = /^(checked|selected|disabled)$/,
                U = {},
                x = 0,
                G = /^-?[\d\.]+$/,
                V = /^data-(.+)$/,
                W = "px",
                M = "setAttribute",
                j = "getAttribute",
                F = function() {
                    var e = H.createElement("p");
                    return {
                        transform: function() {
                            var t,
                                n = ["transform", "webkitTransform", "MozTransform", "OTransform", "msTransform"];
                            for (t = 0; t < n.length; t++)
                                if (n[t] in e.style)
                                    return n[t]
                        }(),
                        classList: "classList" in e
                    }
                }(),
                Y = /\s+/,
                X = String.prototype.toString,
                K = {
                    lineHeight: 1,
                    zoom: 1,
                    zIndex: 1,
                    opacity: 1,
                    boxFlex: 1,
                    WebkitBoxFlex: 1,
                    MozBoxFlex: 1
                },
                z = H.querySelectorAll && function(e) {
                    return H.querySelectorAll(e)
                };
            return F.classList ? (m = function(e, t) {
                return e.classList.contains(t)
            }, B = function(e, t) {
                e.classList.add(t)
            }, I = function(e, t) {
                e.classList.remove(t)
            }) : (m = function(e, t) {
                return r(t).test(e.className)
            }, B = function(e, t) {
                e.className = (e.className + " " + t).trim()
            }, I = function(e, t) {
                e.className = e.className.replace(r(t), " ").trim()
            }), $.prototype = {
                get: function(e) {
                    return this[e] || null
                },
                each: function(e, t) {
                    return i(this, e, t)
                },
                deepEach: function(e, t) {
                    return o(this, e, t)
                },
                map: function(e, t) {
                    var n,
                        r,
                        i = [];
                    for (r = 0; r < this.length; r++)
                        n = e.call(this, this[r], r), t ? t(n) && i.push(n) : i.push(n);
                    return i
                },
                html: function(e, t) {
                    var r = t ? "textContent" : "innerHTML",
                        o = this,
                        a = function(t, r) {
                            i(n(e, o, r), function(e) {
                                t.appendChild(e)
                            })
                        },
                        l = function(n, i) {
                            try {
                                if (t || "string" == typeof e && !b.test(n.tagName))
                                    return n[r] = e
                            } catch (e) {}
                            a(n, i)
                        };
                    return void 0 !== e ? this.empty().each(l) : this[0] ? this[0][r] : ""
                },
                text: function(e) {
                    return this.html(e, !0)
                },
                append: function(e) {
                    var t = this;
                    return this.each(function(r, o) {
                        i(n(e, t, o), function(e) {
                            r.appendChild(e)
                        })
                    })
                },
                prepend: function(e) {
                    var t = this;
                    return this.each(function(r, o) {
                        var a = r.firstChild;
                        i(n(e, t, o), function(e) {
                            r.insertBefore(e, a)
                        })
                    })
                },
                appendTo: function(e, t) {
                    return _.call(this, e, t, function(e, t) {
                        e.appendChild(t)
                    })
                },
                prependTo: function(e, t) {
                    return _.call(this, e, t, function(e, t) {
                        e.insertBefore(t, e.firstChild)
                    }, 1)
                },
                before: function(e) {
                    var t = this;
                    return this.each(function(r, o) {
                        i(n(e, t, o), function(e) {
                            r.parentNode.insertBefore(e, r)
                        })
                    })
                },
                after: function(e) {
                    var t = this;
                    return this.each(function(r, o) {
                        i(n(e, t, o), function(e) {
                            r.parentNode.insertBefore(e, r.nextSibling)
                        }, null, 1)
                    })
                },
                insertBefore: function(e, t) {
                    return _.call(this, e, t, function(e, t) {
                        e.parentNode.insertBefore(t, e)
                    })
                },
                insertAfter: function(e, t) {
                    return _.call(this, e, t, function(e, t) {
                        var n = e.nextSibling;
                        n ? e.parentNode.insertBefore(t, n) : e.parentNode.appendChild(t)
                    }, 1)
                },
                replaceWith: function(e) {
                    var t = this;
                    return this.each(function(r, o) {
                        i(n(e, t, o), function(e) {
                            r.parentNode && r.parentNode.replaceChild(e, r)
                        })
                    })
                },
                clone: function(e) {
                    var t,
                        n,
                        r = [];
                    for (n = 0, t = this.length; n < t; n++)
                        r[n] = h(e || this, this[n]);
                    return A(r)
                },
                addClass: function(e) {
                    return e = X.call(e).split(Y), this.each(function(t) {
                        i(e, function(e) {
                            e && !m(t, f(t, e)) && B(t, f(t, e))
                        })
                    })
                },
                removeClass: function(e) {
                    return e = X.call(e).split(Y), this.each(function(t) {
                        i(e, function(e) {
                            e && m(t, f(t, e)) && I(t, f(t, e))
                        })
                    })
                },
                hasClass: function(e) {
                    return e = X.call(e).split(Y), d(this, function(t) {
                        return d(e, function(e) {
                            return e && m(t, e)
                        })
                    })
                },
                toggleClass: function(e, t) {
                    return e = X.call(e).split(Y), this.each(function(n) {
                        i(e, function(e) {
                            e && (void 0 !== t ? t ? !m(n, e) && B(n, e) : I(n, e) : m(n, e) ? I(n, e) : B(n, e))
                        })
                    })
                },
                show: function(e) {
                    return e = "string" == typeof e ? e : "", this.each(function(t) {
                        t.style.display = e
                    })
                },
                hide: function() {
                    return this.each(function(e) {
                        e.style.display = "none"
                    })
                },
                toggle: function(e, t) {
                    return t = "string" == typeof t ? t : "", "function" != typeof e && (e = null), this.each(function(n) {
                        n.style.display = n.offsetWidth || n.offsetHeight ? "none" : t, e && e.call(n)
                    })
                },
                first: function() {
                    return A(this.length ? this[0] : [])
                },
                last: function() {
                    return A(this.length ? this[this.length - 1] : [])
                },
                next: function() {
                    return this.related("nextSibling")
                },
                previous: function() {
                    return this.related("previousSibling")
                },
                parent: function() {
                    return this.related("parentNode")
                },
                related: function(e) {
                    return A(this.map(function(t) {
                        for (t = t[e]; t && 1 !== t.nodeType;)
                            t = t[e];
                        return t || 0
                    }, function(e) {
                        return e
                    }))
                },
                focus: function() {
                    return this.length && this[0].focus(), this
                },
                blur: function() {
                    return this.length && this[0].blur(), this
                },
                css: function(t, n) {
                    function r(e, t, n) {
                        for (var r in o)
                            if (o.hasOwnProperty(r)) {
                                n = o[r], (t = T(r)) && G.test(n) && !(t in K) && (n += W);
                                try {
                                    e.style[t] = f(e, n)
                                } catch (e) {}
                            }
                    }
                    var i,
                        o = t;
                    return void 0 === n && "string" == typeof t ? (n = this[0], n ? n === H || n === C ? (i = n === H ? A.doc() : A.viewport(), "width" == t ? i.width : "height" == t ? i.height : "") : (t = T(t)) ? e(n, t) : null : null) : ("string" == typeof t && (o = {}, o[t] = n), this.each(r))
                },
                offset: function(e, t) {
                    if (e && "object" == typeof e && ("number" == typeof e.top || "number" == typeof e.left))
                        return this.each(function(t) {
                            p(t, e.left, e.top)
                        });
                    if ("number" == typeof e || "number" == typeof t)
                        return this.each(function(n) {
                            p(n, e, t)
                        });
                    if (!this[0])
                        return {
                            top: 0,
                            left: 0,
                            height: 0,
                            width: 0
                        };
                    var n = this[0],
                        r = n.ownerDocument.documentElement,
                        i = n.getBoundingClientRect(),
                        o = E(),
                        a = n.offsetWidth,
                        l = n.offsetHeight;
                    return {
                        top: i.top + o.y - Math.max(0, r && r.clientTop, H.body.clientTop),
                        left: i.left + o.x - Math.max(0, r && r.clientLeft, H.body.clientLeft),
                        height: l,
                        width: a
                    }
                },
                dim: function() {
                    if (!this.length)
                        return {
                            height: 0,
                            width: 0
                        };
                    var e = this[0],
                        t = 9 == e.nodeType && e.documentElement,
                        n = t || !e.style || e.offsetWidth || e.offsetHeight ? null : function(t) {
                            var n = {
                                position: e.style.position || "",
                                visibility: e.style.visibility || "",
                                display: e.style.display || ""
                            };
                            return t.first().css({
                                position: "absolute",
                                visibility: "hidden",
                                display: "block"
                            }), n
                        }(this),
                        r = t ? Math.max(e.body.scrollWidth, e.body.offsetWidth, t.scrollWidth, t.offsetWidth, t.clientWidth) : e.offsetWidth,
                        i = t ? Math.max(e.body.scrollHeight, e.body.offsetHeight, t.scrollHeight, t.offsetHeight, t.clientHeight) : e.offsetHeight;
                    return n && this.first().css(n), {
                        height: i,
                        width: r
                    }
                },
                attr: function(e, t) {
                    var n,
                        r = this[0];
                    if ("string" != typeof e && !(e instanceof String)) {
                        for (n in e)
                            e.hasOwnProperty(n) && this.attr(n, e[n]);
                        return this
                    }
                    return void 0 === t ? r ? v.test(e) ? !(!k.test(e) || "string" != typeof r[e]) || r[e] : r[j](e) : null : this.each(function(n) {
                        v.test(e) ? n[e] = f(n, t) : n[M](e, f(n, t))
                    })
                },
                removeAttr: function(e) {
                    return this.each(function(t) {
                        k.test(e) ? t[e] = !1 : t.removeAttribute(e)
                    })
                },
                val: function(e) {
                    return "string" == typeof e || "number" == typeof e ? this.attr("value", e) : this.length ? this[0].value : null
                },
                data: function(e, t) {
                    var n,
                        r,
                        o = this[0];
                    return void 0 === t ? o ? (n = s(o), void 0 === e ? (i(o.attributes, function(e) {
                        (r = ("" + e.name).match(V)) && (n[a(r[1])] = u(e.value))
                    }), n) : (void 0 === n[e] && (n[e] = u(this.attr("data-" + l(e)))), n[e])) : null : this.each(function(n) {
                        s(n)[e] = t
                    })
                },
                remove: function() {
                    return this.deepEach(c), this.detach()
                },
                empty: function() {
                    return this.each(function(e) {
                        for (o(e.childNodes, c); e.firstChild;)
                            e.removeChild(e.firstChild)
                    })
                },
                detach: function() {
                    return this.each(function(e) {
                        e.parentNode && e.parentNode.removeChild(e)
                    })
                },
                scrollTop: function(e) {
                    return O.call(this, null, e, "y")
                },
                scrollLeft: function(e) {
                    return O.call(this, e, null, "x")
                }
            }, A.setQueryEngine = function(e) {
                z = e, delete A.setQueryEngine
            }, A.aug = function(e, t) {
                for (var n in e)
                    e.hasOwnProperty(n) && ((t || $.prototype)[n] = e[n])
            }, A.create = function(e) {
                return "string" == typeof e && "" !== e ? function() {
                    if (P.test(e))
                        return [N(e)];
                    var t = e.match(/^\s*<([^\s>]+)/),
                        n = H.createElement("div"),
                        r = [],
                        o = t ? R[t[1].toLowerCase()] : null,
                        a = o ? o[2] + 1 : 1,
                        l = o && o[3],
                        s = "parentNode";
                    for (n.innerHTML = o ? o[0] + e + o[1] : e; a--;)
                        n = n.firstChild;
                    l && n && 1 !== n.nodeType && (n = n.nextSibling);
                    do {
                        t && 1 != n.nodeType || r.push(n)
                    } while (n = n.nextSibling);
                    return i(r, function(e) {
                        e[s] && e[s].removeChild(e)
                    }), r
                }() : t(e) ? [e.cloneNode(!0)] : []
            }, A.doc = function() {
                var e = A.viewport();
                return {
                    width: Math.max(H.body.scrollWidth, g.scrollWidth, e.width),
                    height: Math.max(H.body.scrollHeight, g.scrollHeight, e.height)
                }
            }, A.firstChild = function(e) {
                for (var t, n = e.childNodes, r = 0, i = n && n.length || 0; r < i; r++)
                    1 === n[r].nodeType && (t = n[i = r]);
                return t
            }, A.viewport = function() {
                return {
                    width: C.innerWidth,
                    height: C.innerHeight
                }
            }, A.isAncestor = "compareDocumentPosition" in g ? function(e, t) {
                return 16 == (16 & e.compareDocumentPosition(t))
            } : function(e, t) {
                return e !== t && e.contains(t)
            }, A
        })
    }, {}],
    5: [function(e, t, n) {
        "use strict";
        function r(e) {
            return e && e.__esModule ? e : {
                default: e
            }
        }
        function i(e) {
            if (e && e.__esModule)
                return e;
            var t = {};
            if (null != e)
                for (var n in e)
                    Object.prototype.hasOwnProperty.call(e, n) && (t[n] = e[n]);
            return t.default = e, t
        }
        function o() {
            var e = new l.HandlebarsEnvironment;
            return _.extend(e, l), e.SafeString = c.default, e.Exception = d.default, e.Utils = _, e.escapeExpression = _.escapeExpression, e.VM = f, e.template = function(t) {
                return f.template(t, e)
            }, e
        }
        n.__esModule = !0;
        var a = e("./handlebars/base"),
            l = i(a),
            s = e("./handlebars/safe-string"),
            c = r(s),
            u = e("./handlebars/exception"),
            d = r(u),
            T = e("./handlebars/utils"),
            _ = i(T),
            p = e("./handlebars/runtime"),
            f = i(p),
            O = e("./handlebars/no-conflict"),
            $ = r(O),
            h = o();
        h.create = o, $.default(h), h.default = h, n.default = h, t.exports = n.default
    }, {
        "./handlebars/base": 6,
        "./handlebars/exception": 9,
        "./handlebars/no-conflict": 19,
        "./handlebars/runtime": 20,
        "./handlebars/safe-string": 21,
        "./handlebars/utils": 22
    }],
    6: [function(e, t, n) {
        "use strict";
        function r(e) {
            return e && e.__esModule ? e : {
                default: e
            }
        }
        function i(e, t, n) {
            this.helpers = e || {}, this.partials = t || {}, this.decorators = n || {}, s.registerDefaultHelpers(this), c.registerDefaultDecorators(this)
        }
        n.__esModule = !0, n.HandlebarsEnvironment = i;
        var o = e("./utils"),
            a = e("./exception"),
            l = r(a),
            s = e("./helpers"),
            c = e("./decorators"),
            u = e("./logger"),
            d = r(u);
        n.VERSION = "4.0.11";
        n.COMPILER_REVISION = 7;
        var T = {
            1: "<= 1.0.rc.2",
            2: "== 1.0.0-rc.3",
            3: "== 1.0.0-rc.4",
            4: "== 1.x.x",
            5: "== 2.0.0-alpha.x",
            6: ">= 2.0.0-beta.1",
            7: ">= 4.0.0"
        };
        n.REVISION_CHANGES = T;
        i.prototype = {
            constructor: i,
            logger: d.default,
            log: d.default.log,
            registerHelper: function(e, t) {
                if ("[object Object]" === o.toString.call(e)) {
                    if (t)
                        throw new l.default("Arg not supported with multiple helpers");
                    o.extend(this.helpers, e)
                } else
                    this.helpers[e] = t
            },
            unregisterHelper: function(e) {
                delete this.helpers[e]
            },
            registerPartial: function(e, t) {
                if ("[object Object]" === o.toString.call(e))
                    o.extend(this.partials, e);
                else {
                    if (void 0 === t)
                        throw new l.default('Attempting to register a partial called "' + e + '" as undefined');
                    this.partials[e] = t
                }
            },
            unregisterPartial: function(e) {
                delete this.partials[e]
            },
            registerDecorator: function(e, t) {
                if ("[object Object]" === o.toString.call(e)) {
                    if (t)
                        throw new l.default("Arg not supported with multiple decorators");
                    o.extend(this.decorators, e)
                } else
                    this.decorators[e] = t
            },
            unregisterDecorator: function(e) {
                delete this.decorators[e]
            }
        };
        var _ = d.default.log;
        n.log = _, n.createFrame = o.createFrame, n.logger = d.default
    }, {
        "./decorators": 7,
        "./exception": 9,
        "./helpers": 10,
        "./logger": 18,
        "./utils": 22
    }],
    7: [function(e, t, n) {
        "use strict";
        function r(e) {
            o.default(e)
        }
        n.__esModule = !0, n.registerDefaultDecorators = r;
        var i = e("./decorators/inline"),
            o = function(e) {
                return e && e.__esModule ? e : {
                    default: e
                }
            }(i)
    }, {
        "./decorators/inline": 8
    }],
    8: [function(e, t, n) {
        "use strict";
        n.__esModule = !0;
        var r = e("../utils");
        n.default = function(e) {
            e.registerDecorator("inline", function(e, t, n, i) {
                var o = e;
                return t.partials || (t.partials = {}, o = function(i, o) {
                    var a = n.partials;
                    n.partials = r.extend({}, a, t.partials);
                    var l = e(i, o);
                    return n.partials = a, l
                }), t.partials[i.args[0]] = i.fn, o
            })
        }, t.exports = n.default
    }, {
        "../utils": 22
    }],
    9: [function(e, t, n) {
        "use strict";
        function r(e, t) {
            var n = t && t.loc,
                o = void 0,
                a = void 0;
            n && (o = n.start.line, a = n.start.column, e += " - " + o + ":" + a);
            for (var l = Error.prototype.constructor.call(this, e), s = 0; s < i.length; s++)
                this[i[s]] = l[i[s]];
            Error.captureStackTrace && Error.captureStackTrace(this, r);
            try {
                n && (this.lineNumber = o, Object.defineProperty ? Object.defineProperty(this, "column", {
                    value: a,
                    enumerable: !0
                }) : this.column = a)
            } catch (e) {}
        }
        n.__esModule = !0;
        var i = ["description", "fileName", "lineNumber", "message", "name", "number", "stack"];
        r.prototype = new Error, n.default = r, t.exports = n.default
    }, {}],
    10: [function(e, t, n) {
        "use strict";
        function r(e) {
            return e && e.__esModule ? e : {
                default: e
            }
        }
        function i(e) {
            a.default(e), s.default(e), u.default(e), T.default(e), p.default(e), O.default(e), h.default(e)
        }
        n.__esModule = !0, n.registerDefaultHelpers = i;
        var o = e("./helpers/block-helper-missing"),
            a = r(o),
            l = e("./helpers/each"),
            s = r(l),
            c = e("./helpers/helper-missing"),
            u = r(c),
            d = e("./helpers/if"),
            T = r(d),
            _ = e("./helpers/log"),
            p = r(_),
            f = e("./helpers/lookup"),
            O = r(f),
            $ = e("./helpers/with"),
            h = r($)
    }, {
        "./helpers/block-helper-missing": 11,
        "./helpers/each": 12,
        "./helpers/helper-missing": 13,
        "./helpers/if": 14,
        "./helpers/log": 15,
        "./helpers/lookup": 16,
        "./helpers/with": 17
    }],
    11: [function(e, t, n) {
        "use strict";
        n.__esModule = !0;
        var r = e("../utils");
        n.default = function(e) {
            e.registerHelper("blockHelperMissing", function(t, n) {
                var i = n.inverse,
                    o = n.fn;
                if (!0 === t)
                    return o(this);
                if (!1 === t || null == t)
                    return i(this);
                if (r.isArray(t))
                    return t.length > 0 ? (n.ids && (n.ids = [n.name]), e.helpers.each(t, n)) : i(this);
                if (n.data && n.ids) {
                    var a = r.createFrame(n.data);
                    a.contextPath = r.appendContextPath(n.data.contextPath, n.name), n = {
                        data: a
                    }
                }
                return o(t, n)
            })
        }, t.exports = n.default
    }, {
        "../utils": 22
    }],
    12: [function(e, t, n) {
        "use strict";
        n.__esModule = !0;
        var r = e("../utils"),
            i = e("../exception"),
            o = function(e) {
                return e && e.__esModule ? e : {
                    default: e
                }
            }(i);
        n.default = function(e) {
            e.registerHelper("each", function(e, t) {
                function n(t, n, o) {
                    c && (c.key = t, c.index = n, c.first = 0 === n, c.last = !!o, u && (c.contextPath = u + t)), s += i(e[t], {
                        data: c,
                        blockParams: r.blockParams([e[t], t], [u + t, null])
                    })
                }
                if (!t)
                    throw new o.default("Must pass iterator to #each");
                var i = t.fn,
                    a = t.inverse,
                    l = 0,
                    s = "",
                    c = void 0,
                    u = void 0;
                if (t.data && t.ids && (u = r.appendContextPath(t.data.contextPath, t.ids[0]) + "."), r.isFunction(e) && (e = e.call(this)), t.data && (c = r.createFrame(t.data)), e && "object" == typeof e)
                    if (r.isArray(e))
                        for (var d = e.length; l < d; l++)
                            l in e && n(l, l, l === e.length - 1);
                    else {
                        var T = void 0;
                        for (var _ in e)
                            e.hasOwnProperty(_) && (void 0 !== T && n(T, l - 1), T = _, l++);
                        void 0 !== T && n(T, l - 1, !0)
                    }
                return 0 === l && (s = a(this)), s
            })
        }, t.exports = n.default
    }, {
        "../exception": 9,
        "../utils": 22
    }],
    13: [function(e, t, n) {
        "use strict";
        n.__esModule = !0;
        var r = e("../exception"),
            i = function(e) {
                return e && e.__esModule ? e : {
                    default: e
                }
            }(r);
        n.default = function(e) {
            e.registerHelper("helperMissing", function() {
                if (1 !== arguments.length)
                    throw new i.default('Missing helper: "' + arguments[arguments.length - 1].name + '"')
            })
        }, t.exports = n.default
    }, {
        "../exception": 9
    }],
    14: [function(e, t, n) {
        "use strict";
        n.__esModule = !0;
        var r = e("../utils");
        n.default = function(e) {
            e.registerHelper("if", function(e, t) {
                return r.isFunction(e) && (e = e.call(this)), !t.hash.includeZero && !e || r.isEmpty(e) ? t.inverse(this) : t.fn(this)
            }), e.registerHelper("unless", function(t, n) {
                return e.helpers.if.call(this, t, {
                    fn: n.inverse,
                    inverse: n.fn,
                    hash: n.hash
                })
            })
        }, t.exports = n.default
    }, {
        "../utils": 22
    }],
    15: [function(e, t, n) {
        "use strict";
        n.__esModule = !0, n.default = function(e) {
            e.registerHelper("log", function() {
                for (var t = [void 0], n = arguments[arguments.length - 1], r = 0; r < arguments.length - 1; r++)
                    t.push(arguments[r]);
                var i = 1;
                null != n.hash.level ? i = n.hash.level : n.data && null != n.data.level && (i = n.data.level), t[0] = i, e.log.apply(e, t)
            })
        }, t.exports = n.default
    }, {}],
    16: [function(e, t, n) {
        "use strict";
        n.__esModule = !0, n.default = function(e) {
            e.registerHelper("lookup", function(e, t) {
                return e && e[t]
            })
        }, t.exports = n.default
    }, {}],
    17: [function(e, t, n) {
        "use strict";
        n.__esModule = !0;
        var r = e("../utils");
        n.default = function(e) {
            e.registerHelper("with", function(e, t) {
                r.isFunction(e) && (e = e.call(this));
                var n = t.fn;
                if (r.isEmpty(e))
                    return t.inverse(this);
                var i = t.data;
                return t.data && t.ids && (i = r.createFrame(t.data), i.contextPath = r.appendContextPath(t.data.contextPath, t.ids[0])), n(e, {
                    data: i,
                    blockParams: r.blockParams([e], [i && i.contextPath])
                })
            })
        }, t.exports = n.default
    }, {
        "../utils": 22
    }],
    18: [function(e, t, n) {
        "use strict";
        n.__esModule = !0;
        var r = e("./utils"),
            i = {
                methodMap: ["debug", "info", "warn", "error"],
                level: "info",
                lookupLevel: function(e) {
                    if ("string" == typeof e) {
                        var t = r.indexOf(i.methodMap, e.toLowerCase());
                        e = t >= 0 ? t : parseInt(e, 10)
                    }
                    return e
                },
                log: function(e) {
                    if (e = i.lookupLevel(e), "undefined" != typeof console && i.lookupLevel(i.level) <= e) {
                        var t = i.methodMap[e];
                        console[t] || (t = "log");
                        for (var n = arguments.length, r = Array(n > 1 ? n - 1 : 0), o = 1; o < n; o++)
                            r[o - 1] = arguments[o];
                        console[t].apply(console, r)
                    }
                }
            };
        n.default = i, t.exports = n.default
    }, {
        "./utils": 22
    }],
    19: [function(e, t, n) {
        (function(e) {
            "use strict";
            n.__esModule = !0, n.default = function(t) {
                var n = void 0 !== e ? e : window,
                    r = n.Handlebars;
                t.noConflict = function() {
                    return n.Handlebars === t && (n.Handlebars = r), t
                }
            }, t.exports = n.default
        }).call(this, "undefined" != typeof global ? global : "undefined" != typeof self ? self : "undefined" != typeof window ? window : {})
    }, {}],
    20: [function(e, t, n) {
        "use strict";
        function r(e) {
            var t = e && e[0] || 1,
                n = f.COMPILER_REVISION;
            if (t !== n) {
                if (t < n) {
                    var r = f.REVISION_CHANGES[n],
                        i = f.REVISION_CHANGES[t];
                    throw new p.default("Template was precompiled with an older version of Handlebars than the current runtime. Please update your precompiler to a newer version (" + r + ") or downgrade your runtime to an older version (" + i + ").")
                }
                throw new p.default("Template was precompiled with a newer version of Handlebars than the current runtime. Please update your runtime to a newer version (" + e[1] + ").")
            }
        }
        function i(e, t) {
            function n(n, r, i) {
                i.hash && (r = T.extend({}, r, i.hash), i.ids && (i.ids[0] = !0)), n = t.VM.resolvePartial.call(this, n, r, i);
                var o = t.VM.invokePartial.call(this, n, r, i);
                if (null == o && t.compile && (i.partials[i.name] = t.compile(n, e.compilerOptions, t), o = i.partials[i.name](r, i)), null != o) {
                    if (i.indent) {
                        for (var a = o.split("\n"), l = 0, s = a.length; l < s && (a[l] || l + 1 !== s); l++)
                            a[l] = i.indent + a[l];
                        o = a.join("\n")
                    }
                    return o
                }
                throw new p.default("The partial " + i.name + " could not be compiled when running in runtime-only mode")
            }
            function r(t) {
                function n(t) {
                    return "" + e.main(i, t, i.helpers, i.partials, a, s, l)
                }
                var o = arguments.length <= 1 || void 0 === arguments[1] ? {} : arguments[1],
                    a = o.data;
                r._setup(o), !o.partial && e.useData && (a = c(t, a));
                var l = void 0,
                    s = e.useBlockParams ? [] : void 0;
                return e.useDepths && (l = o.depths ? t != o.depths[0] ? [t].concat(o.depths) : o.depths : [t]), (n = u(e.main, n, i, o.depths || [], a, s))(t, o)
            }
            if (!t)
                throw new p.default("No environment passed to template");
            if (!e || !e.main)
                throw new p.default("Unknown template object: " + typeof e);
            e.main.decorator = e.main_d, t.VM.checkRevision(e.compiler);
            var i = {
                strict: function(e, t) {
                    if (!(t in e))
                        throw new p.default('"' + t + '" not defined in ' + e);
                    return e[t]
                },
                lookup: function(e, t) {
                    for (var n = e.length, r = 0; r < n; r++)
                        if (e[r] && null != e[r][t])
                            return e[r][t]
                },
                lambda: function(e, t) {
                    return "function" == typeof e ? e.call(t) : e
                },
                escapeExpression: T.escapeExpression,
                invokePartial: n,
                fn: function(t) {
                    var n = e[t];
                    return n.decorator = e[t + "_d"], n
                },
                programs: [],
                program: function(e, t, n, r, i) {
                    var a = this.programs[e],
                        l = this.fn(e);
                    return t || i || r || n ? a = o(this, e, l, t, n, r, i) : a || (a = this.programs[e] = o(this, e, l)), a
                },
                data: function(e, t) {
                    for (; e && t--;)
                        e = e._parent;
                    return e
                },
                merge: function(e, t) {
                    var n = e || t;
                    return e && t && e !== t && (n = T.extend({}, t, e)), n
                },
                nullContext: Object.seal({}),
                noop: t.VM.noop,
                compilerInfo: e.compiler
            };
            return r.isTop = !0, r._setup = function(n) {
                n.partial ? (i.helpers = n.helpers, i.partials = n.partials, i.decorators = n.decorators) : (i.helpers = i.merge(n.helpers, t.helpers), e.usePartial && (i.partials = i.merge(n.partials, t.partials)), (e.usePartial || e.useDecorators) && (i.decorators = i.merge(n.decorators, t.decorators)))
            }, r._child = function(t, n, r, a) {
                if (e.useBlockParams && !r)
                    throw new p.default("must pass block params");
                if (e.useDepths && !a)
                    throw new p.default("must pass parent depths");
                return o(i, t, e[t], n, 0, r, a)
            }, r
        }
        function o(e, t, n, r, i, o, a) {
            function l(t) {
                var i = arguments.length <= 1 || void 0 === arguments[1] ? {} : arguments[1],
                    l = a;
                return !a || t == a[0] || t === e.nullContext && null === a[0] || (l = [t].concat(a)), n(e, t, e.helpers, e.partials, i.data || r, o && [i.blockParams].concat(o), l)
            }
            return l = u(n, l, e, a, r, o), l.program = t, l.depth = a ? a.length : 0, l.blockParams = i || 0, l
        }
        function a(e, t, n) {
            return e ? e.call || n.name || (n.name = e, e = n.partials[e]) : e = "@partial-block" === n.name ? n.data["partial-block"] : n.partials[n.name], e
        }
        function l(e, t, n) {
            var r = n.data && n.data["partial-block"];
            n.partial = !0, n.ids && (n.data.contextPath = n.ids[0] || n.data.contextPath);
            var i = void 0;
            if (n.fn && n.fn !== s && function() {
                n.data = f.createFrame(n.data);
                var e = n.fn;
                i = n.data["partial-block"] = function(t) {
                    var n = arguments.length <= 1 || void 0 === arguments[1] ? {} : arguments[1];
                    return n.data = f.createFrame(n.data), n.data["partial-block"] = r, e(t, n)
                }, e.partials && (n.partials = T.extend({}, n.partials, e.partials))
            }(), void 0 === e && i && (e = i), void 0 === e)
                throw new p.default("The partial " + n.name + " could not be found");
            if (e instanceof Function)
                return e(t, n)
        }
        function s() {
            return ""
        }
        function c(e, t) {
            return t && "root" in t || (t = t ? f.createFrame(t) : {}, t.root = e), t
        }
        function u(e, t, n, r, i, o) {
            if (e.decorator) {
                var a = {};
                t = e.decorator(t, a, n, r && r[0], i, o, r), T.extend(t, a)
            }
            return t
        }
        n.__esModule = !0, n.checkRevision = r, n.template = i, n.wrapProgram = o, n.resolvePartial = a, n.invokePartial = l, n.noop = s;
        var d = e("./utils"),
            T = function(e) {
                if (e && e.__esModule)
                    return e;
                var t = {};
                if (null != e)
                    for (var n in e)
                        Object.prototype.hasOwnProperty.call(e, n) && (t[n] = e[n]);
                return t.default = e, t
            }(d),
            _ = e("./exception"),
            p = function(e) {
                return e && e.__esModule ? e : {
                    default: e
                }
            }(_),
            f = e("./base")
    }, {
        "./base": 6,
        "./exception": 9,
        "./utils": 22
    }],
    21: [function(e, t, n) {
        "use strict";
        function r(e) {
            this.string = e
        }
        n.__esModule = !0, r.prototype.toString = r.prototype.toHTML = function() {
            return "" + this.string
        }, n.default = r, t.exports = n.default
    }, {}],
    22: [function(e, t, n) {
        "use strict";
        function r(e) {
            return d[e]
        }
        function i(e) {
            for (var t = 1; t < arguments.length; t++)
                for (var n in arguments[t])
                    Object.prototype.hasOwnProperty.call(arguments[t], n) && (e[n] = arguments[t][n]);
            return e
        }
        function o(e, t) {
            for (var n = 0, r = e.length; n < r; n++)
                if (e[n] === t)
                    return n;
            return -1
        }
        function a(e) {
            if ("string" != typeof e) {
                if (e && e.toHTML)
                    return e.toHTML();
                if (null == e)
                    return "";
                if (!e)
                    return e + "";
                e = "" + e
            }
            return _.test(e) ? e.replace(T, r) : e
        }
        function l(e) {
            return !e && 0 !== e || !(!O(e) || 0 !== e.length)
        }
        function s(e) {
            var t = i({}, e);
            return t._parent = e, t
        }
        function c(e, t) {
            return e.path = t, e
        }
        function u(e, t) {
            return (e ? e + "." : "") + t
        }
        n.__esModule = !0, n.extend = i, n.indexOf = o, n.escapeExpression = a, n.isEmpty = l, n.createFrame = s, n.blockParams = c, n.appendContextPath = u;
        var d = {
                "&": "&amp;",
                "<": "&lt;",
                ">": "&gt;",
                '"': "&quot;",
                "'": "&#x27;",
                "`": "&#x60;",
                "=": "&#x3D;"
            },
            T = /[&<>"'`=]/g,
            _ = /[&<>"'`=]/,
            p = Object.prototype.toString;
        n.toString = p;
        // https://github.com/bestiejs/lodash/blob/master/LICENSE.txt
        /* eslint-disable func-style */
        var f = function(e) {
            return "function" == typeof e
        };
        f(/x/) && (n.isFunction = f = function(e) {
            return "function" == typeof e && "[object Function]" === p.call(e)
        }), n.isFunction = f;
        var O = Array.isArray || function(e) {
            return !(!e || "object" != typeof e) && "[object Array]" === p.call(e)
        };
        n.isArray = O
    }, {}],
    23: [function(e, t, n) {
        t.exports = e("./dist/cjs/handlebars.runtime").default
    }, {
        "./dist/cjs/handlebars.runtime": 5
    }],
    24: [function(e, t, n) {
        t.exports = e("handlebars/runtime").default
    }, {
        "handlebars/runtime": 23
    }],
    25: [function(e, t, n) {
        /*!
  * @preserve Qwery - A selector engine
  * https://github.com/ded/qwery
  * (c) Dustin Diaz 2014 | License MIT
  */
        !function(e, n, r) {
            void 0 !== t && t.exports ? t.exports = r() : "function" == typeof define && define.amd ? define(r) : n.qwery = r()
        }(0, this, function() {
            function e(e) {
                return [].slice.call(e, 0)
            }
            function t(e) {
                var t;
                return e && "object" == typeof e && (t = e.nodeType) && (1 == t || 9 == t)
            }
            function n(e) {
                return "object" == typeof e && isFinite(e.length)
            }
            function r(e) {
                for (var t = [], r = 0, i = e.length; r < i; ++r)
                    n(e[r]) ? t = t.concat(e[r]) : t[t.length] = e[r];
                return t
            }
            function i(e) {
                var t,
                    n,
                    r = [];
                e:
                for (t = 0; t < e.length; t++) {
                    for (n = 0; n < r.length; n++)
                        if (r[n] == e[t])
                            continue e;
                    r[r.length] = e[t]
                }
                return r
            }
            function o(e) {
                return e ? "string" == typeof e ? a(e)[0] : !e[d] && n(e) ? e[0] : e : s
            }
            function a(i, a) {
                var u,
                    d = o(a);
                return d && i ? i === c || t(i) ? !a || i !== c && t(d) && T(i, d) ? [i] : [] : i && n(i) ? r(i) : s.getElementsByClassName && "string" == i && (u = i.match(l)) ? e(d.getElementsByClassName(u[1])) : i && (i.document || i.nodeType && 9 == i.nodeType) ? a ? [] : [i] : e(d.querySelectorAll(i)) : []
            }
            var l = /^\.([\w\-]+)$/,
                s = document,
                c = window,
                u = s.documentElement,
                d = "nodeType",
                T = "compareDocumentPosition" in u ? function(e, t) {
                    return 16 == (16 & t.compareDocumentPosition(e))
                } : function(e, t) {
                    return (t = t == s || t == window ? u : t) !== e && t.contains(e)
                };
            return a.uniq = i, a
        })
    }, {}],
    26: [function(e, t, n) {
        "use strict";
        var r = e("../templates/copyright.hbs"),
            i = e("@apd/apd-sasskit/src/translations/loc"),
            o = e("../translations/labels.json"),
            a = function() {
                try {
                    var e = document.createElement("div"),
                        t = window.HelpViewer.currentBookLocale;
                    e.className = "copyright-text", e.innerHTML = r(i.currentStrings(o, t)), document.body.appendChild(e)
                } catch (e) {
                    console.error(e)
                }
            };
        t.exports = {
            insert: a
        }
    }, {
        "../templates/copyright.hbs": 33,
        "../translations/labels.json": 36,
        "@apd/apd-sasskit/src/translations/loc": 3
    }],
    27: [function(e, t, n) {
        "use strict";
        function r(e, t) {
            return a(l(e, t))
        }
        function i(e) {
            return Object.keys(e).map(function(t) {
                return encodeURIComponent(t) + "=" + encodeURIComponent(e[t])
            }).join("&")
        }
        function o() {
            return "en_US" === HelpViewer.currentBookLocale && !document.querySelector(".landing.AppleTopic")
        }
        var a = e("bonzo"),
            l = e("qwery"),
            s = e("../templates/feedback.hbs"),
            c = e("@apd/apd-sasskit/src/translations/loc"),
            u = e("../translations/labels.json"),
            d = function() {
                var e = "",
                    t = navigator.userAgent.match(/Mac OS X ([_.\d]+)/);
                return t && (e = t[0].replace(t, "$1").replace(/_/g, ".")), e
            },
            T = function() {
                document.querySelector("#feedback .solicit a").addEventListener("click", function(e) {
                    e.preventDefault(), r("#feedback .solicit").attr("aria-hidden", !0), r("#feedback .choices-label").attr("aria-hidden", !1), r("#feedback form").attr("aria-hidden", !1), r("#feedback form").attr("tabindex", "0"), r("textarea[name=comments]").attr("disabled", !1)
                }), document.querySelector("#feedback form button[name=cancel]").addEventListener("click", function(e) {
                    e.preventDefault(), r("#feedback .solicit").attr("aria-hidden", !1), r("#feedback .choices-label").attr("aria-hidden", !0), r("#feedback form").attr("aria-hidden", !0), r("#feedback form").attr("tabindex", "-1")
                });
                var e = function() {
                    var e = r("#feedback form"),
                        t = window.HelpViewer.acEnvironmentName ? "localhost" : e.attr("action"),
                        n = {
                            helpValue: r("input[name=choice]:checked", e).val(),
                            comments: r("textarea", e).val().replace(/&/g, "&amp;").replace(/>/g, "&gt;").replace(/</g, "&lt;"),
                            topicDate: (new Date).toISOString(),
                            topicID: window.HelpViewer.currentTopicID,
                            topicTitle: window.HelpViewer.currentTopicTitle,
                            bookID: window.HelpViewer.currentBookTitle,
                            appVersion: window.HelpViewer.currentBookVersion,
                            buildVersion: window.HelpViewer.currentBookBuildID,
                            locale: window.HelpViewer.currentBookLocale,
                            source: "help viewer",
                            os: d()
                        },
                        o = document.createElement("script");
                    o.setAttribute("src", t + "?" + i(n)), document.body.appendChild(o)
                };
                document.querySelectorAll(".choices input[name=choice]").forEach(function(e) {
                    e.addEventListener("change", function() {
                        r("#feedback button[name=submit]").attr("disabled", !1)
                    }, !1)
                }), document.querySelector("#feedback form button[name=submit]").addEventListener("click", function(t) {
                    t.preventDefault(), e(), r("#feedback .confirm").attr("aria-hidden", !1), r("#feedback .choices-label").attr("aria-hidden", !0), r("#feedback form").attr("aria-hidden", !0), r("#feedback form").attr("tabindex", "-1")
                })
            },
            _ = function() {
                if (o())
                    try {
                        var e = document.createElement("div");
                        e.setAttribute("id", "feedback"), e.innerHTML = s({
                            loc: c.currentStrings(u, HelpViewer.currentBookLocale),
                            topic: {
                                topicId: window.HelpViewer.currentTopicID,
                                topicName: window.HelpViewer.currentTopicTitle
                            }
                        }), document.body.appendChild(e), T()
                    } catch (e) {
                        document.getElementById("feedback").innerHTML = e
                    }
            };
        t.exports = {
            insert: _
        }
    }, {
        "../templates/feedback.hbs": 35,
        "../translations/labels.json": 36,
        "@apd/apd-sasskit/src/translations/loc": 3,
        bonzo: 4,
        qwery: 25
    }],
    28: [function(e, t, n) {
        "use strict";
        var r = e("./tasks"),
            i = e("./passion-points"),
            o = e("./copyright"),
            a = e("./toc-landing"),
            l = e("./feedback"),
            s = e("./review"),
            c = e("@apd/apd-sasskit/src/translations/loc");
        document.addEventListener("DOMContentLoaded", function() {
            r.init(), i.init(), o.insert(), a.init(), l.insert(), s.insert(), document.body.setAttribute("lang", c.currentLocale)
        })
    }, {
        "./copyright": 26,
        "./feedback": 27,
        "./passion-points": 29,
        "./review": 30,
        "./tasks": 31,
        "./toc-landing": 32,
        "@apd/apd-sasskit/src/translations/loc": 3
    }],
    29: [function(e, t, n) {
        "use strict";
        var r = e("@apd/apd-sasskit/src/js/apd-jskit/modules/passion-points"),
            i = function() {
                if (r.init(), window.HelpViewer && "undefined" !== window.HelpViewer.currentAnchor) {
                    var e = window.HelpViewer.currentAnchor,
                        t = document.querySelector(".PassionPoints > .Feature[aria-controls*='" + e + "']");
                    t && r.openAPDPassionPoint(t)
                }
            };
        t.exports = {
            init: i
        }
    }, {
        "@apd/apd-sasskit/src/js/apd-jskit/modules/passion-points": 1
    }],
    30: [function(e, t, n) {
        "use strict";
        var r = e("../templates/debug.hbs"),
            i = function() {
                if (window.HelpViewer && window.HelpViewer.environmentName) {
                    var e = document.createElement("div");
                    e.setAttribute("id", "debug"), e.innerHTML = r({
                        HelpViewer: HelpViewer,
                        APP_VERSION: APP_VERSION
                    }), document.body.appendChild(e)
                }
            };
        t.exports = {
            insert: i
        }
    }, {
        "../templates/debug.hbs": 34
    }],
    31: [function(e, t, n) {
        "use strict";
        var r = e("@apd/apd-sasskit/src/js/apd-jskit/modules/tasks"),
            i = function() {
                r.init(), window.HelpViewer && (window.HelpViewer.toggleAnchorInWebApp = function(e) {
                    var t = document.querySelector(".Task .TaskButtonName[aria-controls*='" + e + "']");
                    t && r.openAPDSchemaTask(t)
                })
            };
        t.exports = {
            init: i
        }
    }, {
        "@apd/apd-sasskit/src/js/apd-jskit/modules/tasks": 2
    }],
    32: [function(e, t, n) {
        "use strict";
        function r(e) {
            var t = document.querySelector(".show-hide"),
                n = window.HelpViewer.currentBookLocale;
            t.innerHTML = e ? s.get(c, "$LANDING_HIDE_TOC$", n) : s.get(c, "$LANDING_SHOW_TOC$", n), t.classList.toggle("show", e)
        }
        function i(e) {
            e.preventDefault();
            var t = document.querySelector(".show-hide"),
                n = !t.classList.contains("show");
            window.HelpViewer.setSidebarExpanded(n), r(!t.classList.contains("show"))
        }
        
        function o() {
            if (document.body.classList.contains("PassionPoints")) {
                var e = document.createElement("ul");
                e.insertAdjacentHTML("afterbegin", '<li><p><span class="icon-info"></span><a href="" class="show-hide"></a></p></li>'), e.className = "landing-toc-btn";
                var t = document.getElementsByClassName("inner")[0];
                t.parentNode.insertBefore(e, t.nextSibling);
                var n = document.querySelector(".landing-toc-btn li");
                r(HelpViewer.sidebarState === l), n.onclick = i
            }
        }
        function a(e) {
            r(e)
        }
        var l = 1,
            s = e("@apd/apd-sasskit/src/translations/loc"),
            c = e("../translations/labels.json");
        window.HelpViewer.setSidebarStateInWebApp = a, t.exports = {
            init: o
        }
    }, {
        "../translations/labels.json": 36,
        "@apd/apd-sasskit/src/translations/loc": 3
    }],
    33: [function(e, t, n) {
        var r = e("hbsfy/runtime");
        t.exports = r.template({
            compiler: [7, ">= 4.0.0"],
            main: function(e, t, n, r, i) {
                var o,
                    a;
                return "<p>" + (null != (a = null != (a = n.$COPYRIGHT$ || (null != t ? t.$COPYRIGHT$ : t)) ? a : n.helperMissing, o = "function" == typeof a ? a.call(null != t ? t : e.nullContext || {}, {
                    name: "$COPYRIGHT$",
                    hash: {},
                    data: i
                }) : a) ? o : "") + "</p>\n"
            },
            useData: !0
        })
    }, {
        "hbsfy/runtime": 24
    }],
    34: [function(e, t, n) {
        var r = e("hbsfy/runtime");
        t.exports = r.template({
            1: function(e, t, n, r, i) {
                var o;
                return e.escapeExpression(e.lambda(null != (o = null != t ? t.HelpViewer : t) ? o.acEnvironmentName : o, t))
            },
            3: function(e, t, n, r, i) {
                return "undefined"
            },
            5: function(e, t, n, r, i) {
                var o;
                return "    <tr>\n      <td>currentAnchor</td>\n      <td>" + e.escapeExpression(e.lambda(null != (o = null != t ? t.HelpViewer : t) ? o.currentAnchor : o, t)) + "</td>\n    </tr>\n"
            },
            compiler: [7, ">= 4.0.0"],
            main: function(e, t, n, r, i) {
                var o,
                    a,
                    l = null != t ? t : e.nullContext || {},
                    s = e.escapeExpression,
                    c = e.lambda;
                return '<table>\n  <tr>\n      <th colspan="2">Debug info <em>(only visible in review environments)</em></th>\n  </tr>\n  <tr>\n      <td>Harrier</td>\n      <td>' + s((a = null != (a = n.APP_VERSION || (null != t ? t.APP_VERSION : t)) ? a : n.helperMissing, "function" == typeof a ? a.call(l, {
                    name: "APP_VERSION",
                    hash: {},
                    data: i
                }) : a)) + "</td>\n  </tr>\n  <tr>\n    <td>acEnvironment</td>\n    <td>" + (null != (o = n.if.call(l, null != (o = null != t ? t.HelpViewer : t) ? o.acEnvironmentName : o, {
                    name: "if",
                    hash: {},
                    fn: e.program(1, i, 0),
                    inverse: e.program(3, i, 0),
                    data: i
                })) ? o : "") + "</td>\n  </tr>\n  <tr>\n    <td>environmentName</td>\n    <td>" + s(c(null != (o = null != t ? t.HelpViewer : t) ? o.environmentName : o, t)) + "</td>\n  </tr>\n  <tr>\n    <td>currentBookBuildID</td>\n    <td>" + s(c(null != (o = null != t ? t.HelpViewer : t) ? o.currentBookBuildID : o, t)) + "</td>\n  </tr>\n  <tr>\n    <td>currentBookLocale</td>\n    <td>" + s(c(null != (o = null != t ? t.HelpViewer : t) ? o.currentBookLocale : o, t)) + "</td>\n  </tr>\n  <tr>\n    <td>currentBookProduct</td>\n    <td>" + s(c(null != (o = null != t ? t.HelpViewer : t) ? o.currentBookProduct : o, t)) + "</td>\n  </tr>\n  <tr>\n    <td>currentBookProductVersion</td>\n    <td>" + s(c(null != (o = null != t ? t.HelpViewer : t) ? o.currentBookProductVersion : o, t)) + "</td>\n  </tr>\n  <tr>\n    <td>currentBookTitle</td>\n    <td>" + s(c(null != (o = null != t ? t.HelpViewer : t) ? o.currentBookTitle : o, t)) + "</td>\n  </tr>\n  <tr>\n    <td>currentBookVersion</td>\n    <td>" + s(c(null != (o = null != t ? t.HelpViewer : t) ? o.currentBookVersion : o, t)) + "</td>\n  </tr>\n  <tr>\n    <td>currentTopicID</td>\n    <td>" + s(c(null != (o = null != t ? t.HelpViewer : t) ? o.currentTopicID : o, t)) + "</td>\n  </tr>\n  <tr>\n    <td>currentTopicTitle</td>\n    <td>" + s(c(null != (o = null != t ? t.HelpViewer : t) ? o.currentTopicTitle : o, t)) + "</td>\n  </tr>\n" + (null != (o = n.if.call(l, null != (o = null != t ? t.HelpViewer : t) ? o.currentAnchor : o, {
                    name: "if",
                    hash: {},
                    fn: e.program(5, i, 0),
                    inverse: e.noop,
                    data: i
                })) ? o : "") + "  <tr>\n    <td>metaFramework</td>\n    <td>" + s(c(null != (o = null != t ? t.HelpViewer : t) ? o.metaFramework : o, t)) + "</td>\n  </tr>\n</table>\n"
            },
            useData: !0
        })
    }, {
        "hbsfy/runtime": 24
    }],
    35: [function(e, t, n) {
        var r = e("hbsfy/runtime");
        t.exports = r.template({
            compiler: [7, ">= 4.0.0"],
            main: function(e, t, n, r, i) {
                var o,
                    a = e.lambda,
                    l = e.escapeExpression;
                return "<p class='solicit' aria-hidden='false'>\n  " + l(a(null != (o = null != t ? t.loc : t) ? o.$FEEDBACK_CHOICES_LABEL$ : o, t)) + " <a role='button'>" + l(a(null != (o = null != t ? t.loc : t) ? o.$FEEDBACK_LINK$ : o, t)) + "</a>\n</p>\n<p class='choices-label' aria-hidden='true'>\n  " + l(a(null != (o = null != t ? t.loc : t) ? o.$FEEDBACK_CHOICES_LABEL$ : o, t)) + '\n</p>\n<form action="https://wsidecar.apple.com/cgi-bin/fb_hlp/nph-sub/" method="post" name="feedback" aria-hidden=\'true\' tabindex="-1">\n  <input type=\'hidden\' name=\'topicID\' value=\'' + l(a(null != (o = null != t ? t.topic : t) ? o.topicId : o, t)) + "' />\n  <input type='hidden' name='topicName' value='" + l(a(null != (o = null != t ? t.topic : t) ? o.topicName : o, t)) + "' />\n  <div class='choices'>\n    <label><input type='radio' name='choice' value='yes'> " + l(a(null != (o = null != t ? t.loc : t) ? o.$FEEDBACK_CHOICE_AFFIRMATIVE$ : o, t)) + "</label>\n    <label><input type='radio' name='choice' value='somewhat'> " + l(a(null != (o = null != t ? t.loc : t) ? o.$FEEDBACK_CHOICE_TENTATIVE$ : o, t)) + "</label>\n    <label><input type='radio' name='choice' value='no'> " + l(a(null != (o = null != t ? t.loc : t) ? o.$FEEDBACK_CHOICE_NEGATIVE$ : o, t)) + "</label>\n  </div>\n  <label><strong>" + l(a(null != (o = null != t ? t.loc : t) ? o.$FEEDBACK_COMMENT_LABEL$ : o, t)) + "</strong><br/><textarea name='comments' disabled='true'></textarea></label>\n  <p><em>" + (null != (o = a(null != (o = null != t ? t.loc : t) ? o.$FEEDBACK_POLICY_NOTICE$ : o, t)) ? o : "") + "</em></p>\n  <button name='cancel' >" + l(a(null != (o = null != t ? t.loc : t) ? o.$FEEDBACK_CANCEL_BUTTON_LABEL$ : o, t)) + "</button>\n  <button name='submit' disabled='true' >" + l(a(null != (o = null != t ? t.loc : t) ? o.$FEEDBACK_SEND_BUTTON_LABEL$ : o, t)) + "</button>\n</form>\n<p class='confirm' aria-hidden='true'>\n  " + l(a(null != (o = null != t ? t.loc : t) ? o.$FEEDBACK_CONFIRMATION$ : o, t)) + "\n</p>\n"
            },
            useData: !0
        })
    }, {
        "hbsfy/runtime": 24
    }],
    36: [function(e, t, n) {
        t.exports = {
            ar: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "التالي",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "السابق",
                $TOC_BUTTON_LABEL_HIDE$: "إخفاء جدول المحتويات",
                $TOC_BUTTON_LABEL_SHOW$: "إظهار جدول المحتويات",
                $LANDING_HIDE_TOC$: "إخفاء الموضوعات",
                $LANDING_SHOW_TOC$: "تصفح الموضوعات",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            bg: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Следващ",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Предишен",
                $TOC_BUTTON_LABEL_HIDE$: "Скрий съдържание",
                $TOC_BUTTON_LABEL_SHOW$: "Покажи съдържание",
                $LANDING_HIDE_TOC$: "Скриване на теми",
                $LANDING_SHOW_TOC$: "Браузване на теми",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            ca: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Següent",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Anterior",
                $TOC_BUTTON_LABEL_HIDE$: "Ocultar la taula de contingut",
                $TOC_BUTTON_LABEL_SHOW$: "Mostrar la taula de contingut",
                $LANDING_HIDE_TOC$: "Ocultar els temes",
                $LANDING_SHOW_TOC$: "Explorar temes",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            cs: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Další",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Předchozí",
                $TOC_BUTTON_LABEL_HIDE$: "Skrýt obsah",
                $TOC_BUTTON_LABEL_SHOW$: "Zobrazit obsah",
                $LANDING_HIDE_TOC$: "Skrýt témata",
                $LANDING_SHOW_TOC$: "Procházet témata",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            da: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Næste",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Forrige",
                $TOC_BUTTON_LABEL_HIDE$: "Skjul indholdsfortegnelse",
                $TOC_BUTTON_LABEL_SHOW$: "Vis indholdsfortegnelse",
                $LANDING_HIDE_TOC$: "Skjul emner",
                $LANDING_SHOW_TOC$: "Gennemse emner",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            de: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Weiter",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Zurück",
                $TOC_BUTTON_LABEL_HIDE$: "Inhaltsverzeichnis ausblenden",
                $TOC_BUTTON_LABEL_SHOW$: "Inhaltsverzeichnis einblenden",
                $LANDING_HIDE_TOC$: "Themen ausblenden",
                $LANDING_SHOW_TOC$: "Themen durchsuchen",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            el: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Επόμενο",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Προηγούμενο",
                $TOC_BUTTON_LABEL_HIDE$: "Απόκρυψη πίνακα περιεχομένων",
                $TOC_BUTTON_LABEL_SHOW$: "Εμφάνιση πίνακα περιεχομένων",
                $LANDING_HIDE_TOC$: "Απόκρυψη θεμάτων",
                $LANDING_SHOW_TOC$: "Περιήγηση στα θέματα",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            en: {
                $FEEDBACK_CANCEL_BUTTON_LABEL$: "Cancel",
                $FEEDBACK_CHOICES_LABEL$: "Was this help page useful?",
                $FEEDBACK_CHOICE_AFFIRMATIVE$: "Yes. I found the information I was looking for.",
                $FEEDBACK_CHOICE_TENTATIVE$: "Somewhat. I found some of the information I was looking for.",
                $FEEDBACK_CHOICE_NEGATIVE$: "No. I did not find the information I was looking for.",
                $FEEDBACK_COMMENT_LABEL$: "Comments:",
                $FEEDBACK_CONFIRMATION$: "Thanks, your feedback has been sent.",
                $FEEDBACK_LINK$: "Send feedback.",
                $FEEDBACK_POLICY_NOTICE$: "Thank you for your comments; we regret that we can’t respond directly to you. Please read <a target='_blank' href='http://www.apple.com/legal/policies/ideas.html'>Apple's Unsolicited Idea Submission Policy</a>.",
                $FEEDBACK_PROMPT$: "Was this page helpful?",
                $FEEDBACK_SEND_BUTTON_LABEL$: "Send feedback",
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Next",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Previous",
                $TOC_BUTTON_LABEL_HIDE$: "Hide table of contents",
                $TOC_BUTTON_LABEL_SHOW$: "Show table of contents",
                $LANDING_HIDE_TOC$: "Hide topics",
                $LANDING_SHOW_TOC$: "Browse topics",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            es: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Siguiente",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Anterior",
                $TOC_BUTTON_LABEL_HIDE$: "Ocultar tabla de contenido",
                $TOC_BUTTON_LABEL_SHOW$: "Mostrar tabla de contenido",
                $LANDING_HIDE_TOC$: "Ocultar temas",
                $LANDING_SHOW_TOC$: "Explorar temas",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            "es-mx": {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Siguiente",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Anterior",
                $TOC_BUTTON_LABEL_HIDE$: "Ocultar tabla de contenido",
                $TOC_BUTTON_LABEL_SHOW$: "Mostrar tabla de contenido",
                $LANDING_HIDE_TOC$: "Ocultar temas",
                $LANDING_SHOW_TOC$: "Explorar temas",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            et: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Järgmine",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Eelmine",
                $TOC_BUTTON_LABEL_HIDE$: "Peida sisukord",
                $TOC_BUTTON_LABEL_SHOW$: "Kuva sisukord",
                $LANDING_HIDE_TOC$: "Peida teemad",
                $LANDING_SHOW_TOC$: "Sirvige teemasid",
                $QUICK_LINKS_LABEL$: "Kiirlingid",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            fi: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Seuraava",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Edellinen",
                $TOC_BUTTON_LABEL_HIDE$: "Kätke sisällysluettelo",
                $TOC_BUTTON_LABEL_SHOW$: "Näytä sisällysluettelo",
                $LANDING_HIDE_TOC$: "Kätke aiheet",
                $LANDING_SHOW_TOC$: "Selaa aiheita",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            fr: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Suivant",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Précédent",
                $TOC_BUTTON_LABEL_HIDE$: "Masquer la table des matières",
                $TOC_BUTTON_LABEL_SHOW$: "Afficher la table des matières",
                $LANDING_HIDE_TOC$: "Masquer les rubriques",
                $LANDING_SHOW_TOC$: "Parcourir les rubriques",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            "fr-ca": {
                // Canadian French (C)
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Suivant",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Précédent",
                $TOC_BUTTON_LABEL_HIDE$: "Masquer la table des matières",
                $TOC_BUTTON_LABEL_SHOW$: "Afficher la table des matières",
                $LANDING_HIDE_TOC$: "Masquer les sujets",
                $LANDING_SHOW_TOC$: "Parcourir les sujets",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            he: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "הבא",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "הקודם",
                $TOC_BUTTON_LABEL_HIDE$: "הסתר את תוכן העניינים",
                $TOC_BUTTON_LABEL_SHOW$: "הצג את תוכן העניינים",
                $LANDING_HIDE_TOC$: "הסתר נושאים",
                $LANDING_SHOW_TOC$: "עיין/י בנושאים",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            hi: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "अगला",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "पिछला",
                $TOC_BUTTON_LABEL_HIDE$: "कॉन्टेंट्स की तालिका छिपाएँ",
                $TOC_BUTTON_LABEL_SHOW$: "कॉन्टेंट्स की तालिका दिखाएँ",
                $LANDING_HIDE_TOC$: "विषय छिपाएँ",
                $LANDING_SHOW_TOC$: "विषय ब्राउज़ करें",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            hr: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Sljedeće",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Prethodno",
                $TOC_BUTTON_LABEL_HIDE$: "Skrivanje kazala sadržaja",
                $TOC_BUTTON_LABEL_SHOW$: "Prikaz kazala sadržaja",
                $LANDING_HIDE_TOC$: "Sakrij teme",
                $LANDING_SHOW_TOC$: "Pretražite teme",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            hu: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Következő",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Előző",
                $TOC_BUTTON_LABEL_HIDE$: "Tartalomjegyzék elrejtése",
                $TOC_BUTTON_LABEL_SHOW$: "Tartalomjegyzék megjelenítése",
                $LANDING_HIDE_TOC$: "Témakörök elrejtése",
                $LANDING_SHOW_TOC$: "Témakörök böngészése",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            id: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Berikutnya",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Sebelumnya",
                $TOC_BUTTON_LABEL_HIDE$: "Sembunyikan daftar isi",
                $TOC_BUTTON_LABEL_SHOW$: "Tampilkan daftar isi",
                $LANDING_HIDE_TOC$: "Sembunyikan topik",
                $LANDING_SHOW_TOC$: "Telusuri topik",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            it: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Avanti",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Indietro",
                $TOC_BUTTON_LABEL_HIDE$: "Nascondi indice",
                $TOC_BUTTON_LABEL_SHOW$: "Mostra indice",
                $LANDING_HIDE_TOC$: "Nascondi argomenti",
                $LANDING_SHOW_TOC$: "Sfoglia i contenuti",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            ja: {
                $NO_WORD_BREAKS$: !0,
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "次へ",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "前へ",
                $TOC_BUTTON_LABEL_HIDE$: "目次を隠す",
                $TOC_BUTTON_LABEL_SHOW$: "目次を表示",
                $LANDING_HIDE_TOC$: "トピックを隠す",
                $LANDING_SHOW_TOC$: "トピックを表示",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            kk: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Келесі",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Алдыңғы",
                $TOC_BUTTON_LABEL_HIDE$: "Мазмұнды жасыру",
                $TOC_BUTTON_LABEL_SHOW$: "Мазмұнды көрсету",
                $LANDING_HIDE_TOC$: "Тақырыптарды жасыру",
                $LANDING_SHOW_TOC$: "Тақырыптарды шолу",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            ko: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "다음",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "이전",
                $TOC_BUTTON_LABEL_HIDE$: "차례 가리기",
                $TOC_BUTTON_LABEL_SHOW$: "차례 보기",
                $LANDING_HIDE_TOC$: "주제 가리기",
                $LANDING_SHOW_TOC$: "주제 탐색",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            lt: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Kitas",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Ankstesnis",
                $TOC_BUTTON_LABEL_HIDE$: "Slėpti turinį",
                $TOC_BUTTON_LABEL_SHOW$: "Rodyti turinį",
                $LANDING_HIDE_TOC$: "Slėpti temas",
                $LANDING_SHOW_TOC$: "Naršymo temos",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            lv: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Tālāk",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Atpakaļ",
                $TOC_BUTTON_LABEL_HIDE$: "Paslēpt satura rādītāju",
                $TOC_BUTTON_LABEL_SHOW$: "Parādīt satura rādītāju",
                $LANDING_HIDE_TOC$: "Slēpt tēmas",
                $LANDING_SHOW_TOC$: "Pārlūkot tēmas",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            ms: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Seterusnya",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Sebelumnya",
                $TOC_BUTTON_LABEL_HIDE$: "Sembunyikan senarai kandungan",
                $TOC_BUTTON_LABEL_SHOW$: "Tunjukkan senarai kandungan",
                $LANDING_HIDE_TOC$: "Sembunyikan topik",
                $LANDING_SHOW_TOC$: "Layari Topik",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            no: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Neste",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Forrige",
                $TOC_BUTTON_LABEL_HIDE$: "Skjul innholdsfortegnelse",
                $TOC_BUTTON_LABEL_SHOW$: "Vis innholdsfortegnelse",
                $LANDING_HIDE_TOC$: "Skjul emner",
                $LANDING_SHOW_TOC$: "Bla gjennom emner",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            nl: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Volgende",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Vorige",
                $TOC_BUTTON_LABEL_HIDE$: "Verberg inhoudsopgave",
                $TOC_BUTTON_LABEL_SHOW$: "Toon inhoudsopgave",
                $LANDING_HIDE_TOC$: "Verberg onderwerpen",
                $LANDING_SHOW_TOC$: "Blader door onderwerpen",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            pl: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Następny",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Poprzedni",
                $TOC_BUTTON_LABEL_HIDE$: "Ukryj spis treści",
                $TOC_BUTTON_LABEL_SHOW$: "Pokaż spis treści",
                $LANDING_HIDE_TOC$: "Ukryj tematy",
                $LANDING_SHOW_TOC$: "Przeglądaj tematy",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            pt: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Seguinte",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Anterior",
                $TOC_BUTTON_LABEL_HIDE$: "Ocultar índice",
                $TOC_BUTTON_LABEL_SHOW$: "Mostrar índice",
                $LANDING_HIDE_TOC$: "Ocultar temas",
                $LANDING_SHOW_TOC$: "Navegar Temas",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            "pt-pt": {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Seguinte",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Anterior",
                $TOC_BUTTON_LABEL_HIDE$: "Ocultar índice",
                $TOC_BUTTON_LABEL_SHOW$: "Mostrar índice",
                $LANDING_HIDE_TOC$: "Ocultar tópicos",
                $LANDING_SHOW_TOC$: "Percorrer tópicos",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            ro: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Înainte",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Înapoi",
                $TOC_BUTTON_LABEL_HIDE$: "Ascundeți tabla de materii",
                $TOC_BUTTON_LABEL_SHOW$: "Afișați tabla de materii",
                $LANDING_HIDE_TOC$: "Ascundere subiecte",
                $LANDING_SHOW_TOC$: "Explorați subiectele",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            ru: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Далее",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Назад",
                $TOC_BUTTON_LABEL_HIDE$: "Скрыть содержание",
                $TOC_BUTTON_LABEL_SHOW$: "Показать содержание",
                $LANDING_HIDE_TOC$: "Скрыть темы",
                $LANDING_SHOW_TOC$: "Оглавление",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            sk: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Ďalšie",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Predošlé",
                $TOC_BUTTON_LABEL_HIDE$: "Skryť obsah",
                $TOC_BUTTON_LABEL_SHOW$: "Zobraziť obsah",
                $LANDING_HIDE_TOC$: "Skryť témy",
                $LANDING_SHOW_TOC$: "Prechádzať témy",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            sl: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Ďalšie",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Predošlé",
                $TOC_BUTTON_LABEL_HIDE$: "Skrij kazalo vsebine ",
                $TOC_BUTTON_LABEL_SHOW$: "Prikaži kazalo vsebine",
                $LANDING_HIDE_TOC$: "Skrij teme",
                $LANDING_SHOW_TOC$: "Brskajte po temah",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            sq: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Përpara",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Prapa",
                $TOC_BUTTON_LABEL_HIDE$: "Fshih tabelën e përmbajtjes",
                $TOC_BUTTON_LABEL_SHOW$: "Shfaq tabelën e përmbajtjes",
                $LANDING_HIDE_TOC$: "Fshih temat",
                $LANDING_SHOW_TOC$: "Shfletoni temat",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            sr: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Përpara",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Следеће",
                $TOC_BUTTON_LABEL_HIDE$: "Сакриј садржај",
                $TOC_BUTTON_LABEL_SHOW$: "Прикажи садржај",
                $LANDING_HIDE_TOC$: "Sakrij teme",
                $LANDING_SHOW_TOC$: "Прегледање садржаја",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            sv: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Nästa",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Föregående",
                $TOC_BUTTON_LABEL_HIDE$: "Göm innehållsförteckning",
                $TOC_BUTTON_LABEL_SHOW$: "Visa innehållsförteckning",
                $LANDING_HIDE_TOC$: "Göm ämnen",
                $LANDING_SHOW_TOC$: "Bläddra bland ämnen",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            th: {
                $NO_WORD_BREAKS$: !0,
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "ถัดไป",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "ก่อนหน้า",
                $TOC_BUTTON_LABEL_HIDE$: "ซ่อนสารบัญ",
                $TOC_BUTTON_LABEL_SHOW$: "แสดงสารบัญ",
                $LANDING_HIDE_TOC$: "ซ่อนหัวข้อ",
                $LANDING_SHOW_TOC$: "เลือกหาหัวข้อ",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            tr: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Sonraki",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Önceki",
                $TOC_BUTTON_LABEL_HIDE$: "İçindekiler tablosunu gizle",
                $TOC_BUTTON_LABEL_SHOW$: "İçindekiler tablosunu göster",
                $LANDING_HIDE_TOC$: "Konuları gizle",
                $LANDING_SHOW_TOC$: "Konulara Göz At",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            uk: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Далі",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Назад",
                $TOC_BUTTON_LABEL_HIDE$: "Згорнути зміст",
                $TOC_BUTTON_LABEL_SHOW$: "Показати зміст",
                $LANDING_HIDE_TOC$: "Приховати теми",
                $LANDING_SHOW_TOC$: "Переглянути теми",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            vi: {
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "Tiếp",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "Trước",
                $TOC_BUTTON_LABEL_HIDE$: "Ẩn bảng mục lục",
                $TOC_BUTTON_LABEL_SHOW$: "Hiển thị bảng mục lục",
                $LANDING_HIDE_TOC$: "Ẩn chủ đề",
                $LANDING_SHOW_TOC$: "Duyệt chủ đề",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            zh: {
                $NO_WORD_BREAKS$: !0,
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "下一页",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "上一页",
                $TOC_BUTTON_LABEL_HIDE$: "隐藏目录",
                $TOC_BUTTON_LABEL_SHOW$: "显示目录",
                $LANDING_HIDE_TOC$: "隐藏主题",
                $LANDING_SHOW_TOC$: "浏览主题",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            "zh-hk": {
                $NO_WORD_BREAKS$: !0,
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "下一頁",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "上一頁",
                $TOC_BUTTON_LABEL_HIDE$: "隱藏目錄",
                $TOC_BUTTON_LABEL_SHOW$: "顯示目錄",
                $LANDING_HIDE_TOC$: "隱藏主題",
                $LANDING_SHOW_TOC$: "瀏覽主題",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            },
            "zh-tw": {
                $NO_WORD_BREAKS$: !0,
                $NEXT_TOPIC_BUTTON_LABEL_SHORT$: "下一頁",
                $PREV_TOPIC_BUTTON_LABEL_SHORT$: "上一頁",
                $TOC_BUTTON_LABEL_HIDE$: "隱藏目錄",
                $TOC_BUTTON_LABEL_SHOW$: "顯示目錄",
                $LANDING_HIDE_TOC$: "隱藏主題",
                $LANDING_SHOW_TOC$: "瀏覽主題",
                $COPYRIGHT$: "&copy; 2017 Apple Inc. All rights reserved."
            }
        }
    }, {}]
}, {}, [28]);

