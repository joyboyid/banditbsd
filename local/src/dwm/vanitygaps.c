/* Key binding functions */
static void togglegaps(const Arg *arg);

/* Layouts */
static void bstack(Monitor *m);
static void bstackhoriz(Monitor *m);
static void centeredmaster(Monitor *m);
static void centeredfloatingmaster(Monitor *m);
static void deck(Monitor *m);
static void dwindle(Monitor *m);
static void fibonacci(Monitor *m, int s);
static void gaplessgrid(Monitor *m);
static void grid(Monitor *m);
static void horizgrid(Monitor *m);
static void nrowgrid(Monitor *m);
static void spiral(Monitor *m);
static void tile(Monitor *m);

/* Internals */
static void getgaps(Monitor *m, int *g, unsigned int *nc);
static void getfacts(Monitor *m, int msize, int ssize, float *mf, float *sf,
                     int *mr, int *sr);

/* Settings */
#if !PERTAG_PATCH
extern int enablegaps;
#endif // PERTAG_PATCH

void togglegaps(const Arg *arg) {
#if PERTAG_PATCH
    selmon->pertag->enablegaps[selmon->pertag->curtag] =
        !selmon->pertag->enablegaps[selmon->pertag->curtag];
#else
    enablegaps = !enablegaps;
#endif // PERTAG_PATCH
    arrange(NULL);
}

void getgaps(Monitor *m, int *g, unsigned int *nc) {
    unsigned int n, e;
#if PERTAG_PATCH
    e = m->pertag->enablegaps[m->pertag->curtag];
#else
    e = enablegaps;
#endif // PERTAG_PATCH
    Client *c;

    for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++)
        ;
    if (smartgaps && n == 1) {
        e = 0;
    }

    *g  = m->gappx * e;
    *nc = n;
}

void getfacts(Monitor *m, int msize, int ssize, float *mf, float *sf, int *mr,
              int *sr) {
    unsigned int n;
    float        mfacts, sfacts;
    int          mtotal = 0, stotal = 0;
    Client      *c;

    for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++)
        ;
    mfacts = MIN(n, m->nmaster);
    sfacts = n - m->nmaster;

    for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++)
        if (n < m->nmaster)
            mtotal += msize / (mfacts ? mfacts : 1);
        else
            stotal += ssize / (sfacts ? sfacts : 1);

    *mf = mfacts;
    *sf = sfacts;
    *mr = msize - mtotal;
    *sr = ssize - stotal;
}

/***
 * Layouts
 ***/

static void bstack(Monitor *m) {
    unsigned int i, n;
    int          g;
    int          mx = 0, my = 0, mh = 0, mw = 0;
    int          sx = 0, sy = 0, sh = 0, sw = 0;
    float        mfacts, sfacts;
    int          mrest, srest;
    Client      *c;

    getgaps(m, &g, &n);
    if (n == 0)
        return;

    sx = mx = m->wx + g;
    sy = my = m->wy + g;
    sh = mh = m->wh - 2 * g;
    mw = m->ww - 2 * g - g * (MIN(n, m->nmaster) ? MIN(n, m->nmaster) - 1 : 0);
    sw = m->ww - 2 * g - g * (n > m->nmaster ? n - m->nmaster - 1 : 0);

    if (m->nmaster && n > m->nmaster) {
        sh = (mh - g) * (1 - m->mfact);
        mh = mh - g - sh;
        sx = mx;
        sy = my + mh + g;
    }

    getfacts(m, mw, sw, &mfacts, &sfacts, &mrest, &srest);

    for (i = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++) {
        if (i < m->nmaster) {
            resize(c, mx, my, (mw / mfacts) + (i < mrest ? 1 : 0) - (2 * c->bw),
                   mh - (2 * c->bw), 0);
            mx += WIDTH(c) + g;
        } else {
            resize(c, sx, sy,
                   (sw / sfacts) + ((i - m->nmaster) < srest ? 1 : 0) -
                       (2 * c->bw),
                   sh - (2 * c->bw), 0);
            sx += WIDTH(c) + g;
        }
    }
}

static void bstackhoriz(Monitor *m) {
    unsigned int i, n;
    int          g;
    int          mx = 0, my = 0, mh = 0, mw = 0;
    int          sx = 0, sy = 0, sh = 0, sw = 0;
    float        mfacts, sfacts;
    int          mrest, srest;
    Client      *c;

    getgaps(m, &g, &n);
    if (n == 0)
        return;

    sx = mx = m->wx + g;
    sy = my = m->wy + g;
    mh      = m->wh - 2 * g;
    sh      = m->wh - 2 * g - g * (n > m->nmaster ? n - m->nmaster - 1 : 0);
    mw = m->ww - 2 * g - g * (MIN(n, m->nmaster) ? MIN(n, m->nmaster) - 1 : 0);
    sw = m->ww - 2 * g;

    if (m->nmaster && n > m->nmaster) {
        sh = (mh - g) * (1 - m->mfact);
        mh = mh - g - sh;
        sy = my + mh + g;
        sh = m->wh - mh - 2 * g - g * (n > m->nmaster ? n - m->nmaster : 0);
    }

    getfacts(m, mw, sh, &mfacts, &sfacts, &mrest, &srest);

    for (i = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++) {
        if (i < m->nmaster) {
            resize(c, mx, my, (mw / mfacts) + (i < mrest ? 1 : 0) - (2 * c->bw),
                   mh - (2 * c->bw), 0);
            mx += WIDTH(c) + g;
        } else {
            resize(c, sx, sy, sw - (2 * c->bw),
                   (sh / sfacts) + ((i - m->nmaster) < srest ? 1 : 0) -
                       (2 * c->bw),
                   0);
            sy += HEIGHT(c) + g;
        }
    }
}

void centeredmaster(Monitor *m) {
    unsigned int i, n;
    int          g;
    int          mx = 0, my = 0, mh = 0, mw = 0;
    int          lx = 0, ly = 0, lw = 0, lh = 0;
    int          rx = 0, ry = 0, rw = 0, rh = 0;
    float        mfacts = 0, lfacts = 0, rfacts = 0;
    int          mtotal = 0, ltotal = 0, rtotal = 0;
    int          mrest = 0, lrest = 0, rrest = 0;
    Client      *c;

    getgaps(m, &g, &n);
    if (n == 0)
        return;

    unsigned int mcount = !m->nmaster ? n : MIN(n, m->nmaster);
    unsigned int lcount = (n > m->nmaster) ? (n - m->nmaster) / 2 : 0;
    unsigned int rcount = (n > m->nmaster) ? (n - m->nmaster) - lcount : 0;

    mx = m->wx + g;
    my = m->wy + g;
    mh = m->wh - 2 * g - g * (mcount ? mcount - 1 : 0);
    mw = m->ww - 2 * g;
    lh = m->wh - 2 * g - g * (lcount ? lcount - 1 : 0);
    rh = m->wh - 2 * g - g * (rcount ? rcount - 1 : 0);

    if (m->nmaster && n > m->nmaster) {
        if (n - m->nmaster > 1) {
            mw = (m->ww - 2 * g - 2 * g) * m->mfact;
            lw = (m->ww - mw - 2 * g - 2 * g) / 2;
            rw = (m->ww - mw - 2 * g - 2 * g) - lw;
            mx += lw + g;
        } else {
            mw = (mw - g) * m->mfact;
            lw = 0;
            rw = m->ww - mw - g - 2 * g;
        }
        lx = m->wx + g;
        ly = m->wy + g;
        rx = mx + mw + g;
        ry = m->wy + g;
    }

    for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++) {
        if (!m->nmaster || n < m->nmaster)
            mfacts += 1;
        else if ((n - m->nmaster) % 2)
            lfacts += 1;
        else
            rfacts += 1;
    }

    for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++)
        if (!m->nmaster || n < m->nmaster)
            mtotal += mh / (mfacts ? mfacts : 1);
        else if ((n - m->nmaster) % 2)
            ltotal += lh / (lfacts ? lfacts : 1);
        else
            rtotal += rh / (rfacts ? rfacts : 1);

    mrest = mh - mtotal;
    lrest = lh - ltotal;
    rrest = rh - rtotal;

    for (i = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++) {
        if (!m->nmaster || i < m->nmaster) {
            resize(c, mx, my, mw - (2 * c->bw),
                   (mh / mfacts) + (i < mrest ? 1 : 0) - (2 * c->bw), 0);
            my += HEIGHT(c) + g;
        } else {
            if ((i - m->nmaster) % 2) {
                resize(c, lx, ly, lw - (2 * c->bw),
                       (lh / lfacts) +
                           ((i - 2 * m->nmaster) < 2 * lrest ? 1 : 0) -
                           (2 * c->bw),
                       0);
                ly += HEIGHT(c) + g;
            } else {
                resize(c, rx, ry, rw - (2 * c->bw),
                       (rh / rfacts) +
                           ((i - 2 * m->nmaster) < 2 * rrest ? 1 : 0) -
                           (2 * c->bw),
                       0);
                ry += HEIGHT(c) + g;
            }
        }
    }
}

void centeredfloatingmaster(Monitor *m) {
    unsigned int i, n;
    float        mfacts, sfacts;
    float        mivf = 1.0;
    int          g, mrest, srest;
    int          mx = 0, my = 0, mh = 0, mw = 0;
    int          sx = 0, sy = 0, sh = 0, sw = 0;
    Client      *c;

    getgaps(m, &g, &n);
    if (n == 0)
        return;

    sx = mx = m->wx + g;
    sy = my = m->wy + g;
    sh = mh = m->wh - 2 * g;
    mw      = m->ww - 2 * g - g * (n ? n - 1 : 0);
    sw      = m->ww - 2 * g - g * (n > m->nmaster ? n - m->nmaster - 1 : 0);

    if (m->nmaster && n > m->nmaster) {
        mivf = 0.8;
        if (m->ww > m->wh) {
            mw = m->ww * m->mfact -
                 g * mivf * (MIN(n, m->nmaster) ? MIN(n, m->nmaster) - 1 : 0);
            mh = m->wh * 0.9;
        } else {
            mw = m->ww * 0.9 -
                 g * mivf * (MIN(n, m->nmaster) ? MIN(n, m->nmaster) - 1 : 0);
            mh = m->wh * m->mfact;
        }
        mx = m->wx + (m->ww - mw) / 2;
        my = m->wy + (m->wh - mh - 2 * g) / 2;

        sx = m->wx + g;
        sy = m->wy + g;
        sh = m->wh - 2 * g;
    }

    getfacts(m, mw, sw, &mfacts, &sfacts, &mrest, &srest);

    for (i = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++)
        if (i < m->nmaster) {
            resize(c, mx, my, (mw / mfacts) + (i < mrest ? 1 : 0) - (2 * c->bw),
                   mh - (2 * c->bw), 0);
            mx += WIDTH(c) + g * mivf;
        } else {
            resize(c, sx, sy,
                   (sw / sfacts) + ((i - m->nmaster) < srest ? 1 : 0) -
                       (2 * c->bw),
                   sh - (2 * c->bw), 0);
            sx += WIDTH(c) + g;
        }
}

void deck(Monitor *m) {
    unsigned int i, n;
    int          g;
    int          mx = 0, my = 0, mh = 0, mw = 0;
    int          sx = 0, sy = 0, sh = 0, sw = 0;
    float        mfacts, sfacts;
    int          mrest, srest;
    Client      *c;

    getgaps(m, &g, &n);
    if (n == 0)
        return;

    sx = mx = m->wx + g;
    sy = my = m->wy + g;
    sh      = mh =
        m->wh - 2 * g - g * (MIN(n, m->nmaster) ? MIN(n, m->nmaster) - 1 : 0);
    sw = mw = m->ww - 2 * g;

    if (m->nmaster && n > m->nmaster) {
        sw = (mw - g) * (1 - m->mfact);
        mw = mw - g - sw;
        sx = mx + mw + g;
        sh = m->wh - 2 * g;
    }

    getfacts(m, mh, sh, &mfacts, &sfacts, &mrest, &srest);

    if (n - m->nmaster > 0)
        snprintf(m->ltsymbol, sizeof m->ltsymbol, "D %d", n - m->nmaster);

    for (i = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++)
        if (i < m->nmaster) {
            resize(c, mx, my, mw - (2 * c->bw),
                   (mh / mfacts) + (i < mrest ? 1 : 0) - (2 * c->bw), 0);
            my += HEIGHT(c) + g;
        } else {
            resize(c, sx, sy, sw - (2 * c->bw), sh - (2 * c->bw), 0);
        }
}

void fibonacci(Monitor *m, int s) {
    unsigned int i, n;
    int          nx, ny, nw, nh;
    int          g;
    int          nv, hrest = 0, wrest = 0, r = 1;
    Client      *c;

    getgaps(m, &g, &n);
    if (n == 0)
        return;

    nx = m->wx + g;
    ny = m->wy + g;
    nw = m->ww - 2 * g;
    nh = m->wh - 2 * g;

    for (i = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next)) {
        if (r) {
            if ((i % 2 && (nh - g) / 2 <= (bh + 2 * c->bw)) ||
                (!(i % 2) && (nw - g) / 2 <= (bh + 2 * c->bw))) {
                r = 0;
            }
            if (r && i < n - 1) {
                if (i % 2) {
                    nv    = (nh - g) / 2;
                    hrest = nh - 2 * nv - g;
                    nh    = nv;
                } else {
                    nv    = (nw - g) / 2;
                    wrest = nw - 2 * nv - g;
                    nw    = nv;
                }

                if ((i % 4) == 2 && !s)
                    nx += nw + g;
                else if ((i % 4) == 3 && !s)
                    ny += nh + g;
            }

            if ((i % 4) == 0) {
                if (s) {
                    ny += nh + g;
                    nh += hrest;
                } else {
                    nh -= hrest;
                    ny -= nh + g;
                }
            } else if ((i % 4) == 1) {
                nx += nw + g;
                nw += wrest;
            } else if ((i % 4) == 2) {
                ny += nh + g;
                nh += hrest;
                if (i < n - 1)
                    nw += wrest;
            } else if ((i % 4) == 3) {
                if (s) {
                    nx += nw + g;
                    nw -= wrest;
                } else {
                    nw -= wrest;
                    nx -= nw + g;
                    nh += hrest;
                }
            }
            if (i == 0) {
                if (n != 1) {
                    nw    = (m->ww - g - 2 * g) -
                            (m->ww - g - 2 * g) * (1 - m->mfact);
                    wrest = 0;
                }
                ny = m->wy + g;
            } else if (i == 1)
                nw = m->ww - nw - g - 2 * g;
            i++;
        }

        resize(c, nx, ny, nw - (2 * c->bw), nh - (2 * c->bw), False);
    }
}

void dwindle(Monitor *m) { fibonacci(m, 1); }

void spiral(Monitor *m) { fibonacci(m, 0); }

void gaplessgrid(Monitor *m) {
    unsigned int i, n;
    int          x, y, cols, rows, ch, cw, cn, rn, rrest, crest;
    int          g;
    Client      *c;

    getgaps(m, &g, &n);
    if (n == 0)
        return;

    for (cols = 0; cols <= n / 2; cols++)
        if (cols * cols >= n)
            break;
    if (n == 5)
        cols = 2;
    rows = n / cols;
    cn = rn = 0;

    ch    = (m->wh - 2 * g - g * (rows > 1 ? rows - 1 : 0)) / (rows ? rows : 1);
    cw    = (m->ww - 2 * g - g * (cols > 1 ? cols - 1 : 0)) / (cols ? cols : 1);
    rrest = (m->wh - 2 * g - g * (rows > 1 ? rows - 1 : 0)) - ch * rows;
    crest = (m->ww - 2 * g - g * (cols > 1 ? cols - 1 : 0)) - cw * cols;
    x     = m->wx + g;
    y     = m->wy + g;

    for (i = 0, c = nexttiled(m->clients); c; i++, c = nexttiled(c->next)) {
        if (i / rows + 1 > cols - n % cols) {
            rows  = n / cols + 1;
            ch    = (m->wh - 2 * g - g * (rows > 1 ? rows - 1 : 0)) / rows;
            rrest = (m->wh - 2 * g - g * (rows > 1 ? rows - 1 : 0)) - ch * rows;
        }
        resize(c, x, y + rn * (ch + g) + MIN(rn, rrest),
               cw + (cn < crest ? 1 : 0) - 2 * c->bw,
               ch + (rn < rrest ? 1 : 0) - 2 * c->bw, 0);
        rn++;
        if (rn >= rows) {
            rn = 0;
            x += cw + g + (cn < crest ? 1 : 0);
            cn++;
        }
    }
}

void grid(Monitor *m) {
    unsigned int i, n;
    int          cx, cy, cw, ch, cc, cr, chrest, cwrest, cols, rows;
    int          g;
    Client      *c;

    getgaps(m, &g, &n);
    if (n == 0)
        return;

    for (rows = 0; rows <= n / 2; rows++)
        if (rows * rows >= n)
            break;
    cols = (rows && (rows - 1) * rows >= n) ? rows - 1 : rows;

    ch = (m->wh - 2 * g - g * (rows > 1 ? rows - 1 : 0)) / (rows ? rows : 1);
    cw = (m->ww - 2 * g - g * (cols > 1 ? cols - 1 : 0)) / (cols ? cols : 1);
    chrest = (m->wh - 2 * g - g * (rows > 1 ? rows - 1 : 0)) - ch * rows;
    cwrest = (m->ww - 2 * g - g * (cols > 1 ? cols - 1 : 0)) - cw * cols;
    for (i = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++) {
        cc = i / (rows ? rows : 1);
        cr = i % (rows ? rows : 1);
        cx = m->wx + g + cc * (cw + g) + MIN(cc, cwrest);
        cy = m->wy + g + cr * (ch + g) + MIN(cr, chrest);
        resize(c, cx, cy, cw + (cc < cwrest ? 1 : 0) - 2 * c->bw,
               ch + (cr < chrest ? 1 : 0) - 2 * c->bw, False);
    }
}

void horizgrid(Monitor *m) {
    Client      *c;
    unsigned int n, i;
    int          g;
    int          mx = 0, my = 0, mh = 0, mw = 0;
    int          sx = 0, sy = 0, sh = 0, sw = 0;
    int          ntop, nbottom = 1;
    float        mfacts, sfacts;
    int          mrest, srest;

    getgaps(m, &g, &n);
    if (n == 0)
        return;

    if (n <= 2)
        ntop = n;
    else {
        ntop    = n / 2;
        nbottom = n - ntop;
    }
    sx = mx = m->wx + g;
    sy = my = m->wy + g;
    sh = mh = m->wh - 2 * g;
    sw = mw = m->ww - 2 * g;

    if (n > ntop) {
        sh = (mh - g) / 2;
        mh = mh - g - sh;
        sy = my + mh + g;
        mw = m->ww - 2 * g - g * (ntop > 1 ? ntop - 1 : 0);
        sw = m->ww - 2 * g - g * (nbottom > 1 ? nbottom - 1 : 0);
    }

    mfacts = ntop;
    sfacts = nbottom;
    mrest  = mw - (mw / (ntop ? ntop : 1)) * ntop;
    srest  = sw - (sw / (nbottom ? nbottom : 1)) * nbottom;

    for (i = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++)
        if (i < ntop) {
            resize(c, mx, my, (mw / mfacts) + (i < mrest ? 1 : 0) - (2 * c->bw),
                   mh - (2 * c->bw), 0);
            mx += WIDTH(c) + g;
        } else {
            resize(c, sx, sy,
                   (sw / sfacts) + ((i - ntop) < srest ? 1 : 0) - (2 * c->bw),
                   sh - (2 * c->bw), 0);
            sx += WIDTH(c) + g;
        }
}

void nrowgrid(Monitor *m) {
    unsigned int n;
    int          ri = 0, ci = 0;
    int          g;
    unsigned int cx, cy, cw, ch;
    unsigned int uw = 0, uh = 0, uc = 0;
    unsigned int cols, rows = m->nmaster + 1;
    Client      *c;

    getgaps(m, &g, &n);

    if (n == 0)
        return;

    if (FORCE_VSPLIT && n == 2)
        rows = 1;

    if (n < rows)
        rows = n;

    cols = n / rows;
    uc   = cols;
    cy   = m->wy + g;
    ch   = (m->wh - 2 * g - g * (rows > 1 ? rows - 1 : 0)) / rows;
    uh   = ch;

    for (c = nexttiled(m->clients); c; c = nexttiled(c->next), ci++) {
        if (ci == cols) {
            uw = 0;
            ci = 0;
            ri++;

            cols = (n - uc) / ((rows - ri) ? (rows - ri) : 1);
            uc += cols;
            cy = m->wy + g + uh + g;
            uh += ch + g;
        }

        cx = m->wx + g + uw;
        cw = (m->ww - 2 * g - uw) / ((cols - ci) ? (cols - ci) : 1);
        uw += cw + g;

        resize(c, cx, cy, cw - (2 * c->bw), ch - (2 * c->bw), 0);
    }
}

static void tile(Monitor *m) {
    unsigned int i, n;
    int          g;
    int          mx = 0, my = 0, mh = 0, mw = 0;
    int          sx = 0, sy = 0, sh = 0, sw = 0;
    float        mfacts, sfacts;
    int          mrest, srest;
    Client      *c;

    getgaps(m, &g, &n);
    if (n == 0)
        return;

    sx = mx = m->wx + g;
    sy = my = m->wy + g;
    mh = m->wh - 2 * g - g * (MIN(n, m->nmaster) ? MIN(n, m->nmaster) - 1 : 0);
    sh = m->wh - 2 * g - g * (n > m->nmaster ? n - m->nmaster - 1 : 0);
    sw = mw = m->ww - 2 * g;

    if (m->nmaster && n > m->nmaster) {
        sw = (mw - g) * (1 - m->mfact);
        mw = mw - g - sw;
        sx = mx + mw + g;
    }

    getfacts(m, mh, sh, &mfacts, &sfacts, &mrest, &srest);

    for (i = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++)
        if (i < m->nmaster) {
            resize(c, mx, my, mw - (2 * c->bw),
                   (mh / mfacts) + (i < mrest ? 1 : 0) - (2 * c->bw), 0);
            my += HEIGHT(c) + g;
        } else {
            resize(c, sx, sy, sw - (2 * c->bw),
                   (sh / sfacts) + ((i - m->nmaster) < srest ? 1 : 0) -
                       (2 * c->bw),
                   0);
            sy += HEIGHT(c) + g;
        }
}
