
% qdissertation.cls -- Qyber dissertation class
% Engines: pdfLaTeX, XeLaTeX, LuaLaTeX.
% Layout: A4, 12pt, 3cm margins; single line spacing; ragged-right;
%   main text 12pt, footnotes and captions at least 11pt.
% Chapter style: number/letter and title on first line; header has a top bar
%   and "Chapter N" or "Appendix A" label.
%
% SPDX-FileCopyrightText: 2026 Frank Langbein <frank@langbein.org>
% SPDX-License-Identifier: LPPL-1.3c
% This file may be distributed and/or modified under the terms of the
% LaTeX Project Public License (LPPL), version 1.3c.
% The latest version of this license is at https://www.latex-project.org/lppl/
%
% User commands (set in preamble): \title, \author, \degree, \university, \date;
%   \license{SPDX-ID}, \copyrightholder{}, \licenseyear{} (optional).
% In document: \maketitle{abstract text}; \bib{basename} for bibliography.
% Override acronym file: \renewcommand{\qdissertationacronymfile}{yourfile.tex}.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{qdissertation}[2026/02/27 Qyber dissertation class]

\makeatletter

% ------------------------------------------------------------------------------
% Class options
% ------------------------------------------------------------------------------
% Font: mixed (default) = sans-serif text + serif math; sans = all sans-serif;
%   serif = serif text and math.
% Layout: oneside (default) or twoside for double-sided printing.
% Citation: numeric (default) [1], [1,2] or harvard (Author, 2000).
% Line spacing: single (default); onehalfspacing; linespread115 (1.15) or linespread12 (1.2)
%   for institutions allowing 1.0--1.3 (PATS allows up to 1.3).
% Any other option is passed through to the underlying book class.

\newif\ifqdissertation@font@mixed
\newif\ifqdissertation@font@sans
\newif\ifqdissertation@font@serif
\newif\ifqdissertation@twoside
\newif\ifqdissertation@cite@harvard

\qdissertation@font@mixedtrue
\qdissertation@font@sansfalse
\qdissertation@font@seriffalse
\qdissertation@twosidefalse
\qdissertation@cite@harvardfalse

\DeclareOption{mixed}{%
  \qdissertation@font@mixedtrue
  \qdissertation@font@sansfalse
  \qdissertation@font@seriffalse
}
\DeclareOption{sans}{%
  \qdissertation@font@mixedfalse
  \qdissertation@font@sanstrue
  \qdissertation@font@seriffalse
}
\DeclareOption{serif}{%
  \qdissertation@font@mixedfalse
  \qdissertation@font@sansfalse
  \qdissertation@font@seriftrue
}

\DeclareOption{harvard}{\qdissertation@cite@harvardtrue}
\DeclareOption{numeric}{\qdissertation@cite@harvardfalse}

\DeclareOption{twoside}{%
  \PassOptionsToClass{twoside}{book}%
  \qdissertation@twosidetrue
}
\DeclareOption{oneside}{%
  \PassOptionsToClass{oneside}{book}%
  \qdissertation@twosidefalse
}

\newif\ifqdissertation@onehalfspacing
\newif\ifqdissertation@linespread
\qdissertation@onehalfspacingfalse
\qdissertation@linespreadfalse
\DeclareOption{onehalfspacing}{\qdissertation@onehalfspacingtrue}
\DeclareOption{linespread115}{\qdissertation@linespreadtrue\def\qdissertation@linespreadval{1.15}}
\DeclareOption{linespread12}{\qdissertation@linespreadtrue\def\qdissertation@linespreadval{1.2}}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}

\ProcessOptions\relax
\LoadClass[12pt,a4paper]{book}

% Use roman numerals (i, ii, ...) for front matter from the very first page,
% and treat the document as front matter until \mainmatter is called.
% In front matter: sections unnumbered (secnumdepth -1), TOC to chapter level only (tocdepth 0).
% Close LOF/LOT/LOA write streams after .aux was read so \listoffigures etc.\ can read the files.
\AtBeginDocument{%
  \@ifundefined{qdissertation@opened@lof}{}{\immediate\closeout\tf@lof}%
  \@ifundefined{qdissertation@opened@lot}{}{\immediate\closeout\tf@lot}%
  \@ifundefined{qdissertation@opened@loa}{}{\immediate\closeout\tf@loa}%
  \@mainmatterfalse
  \pagenumbering{roman}%
  \setcounter{secnumdepth}{-1}%
  \setcounter{tocdepth}{0}%
}
% Restore section numbering and TOC depth in main matter (no etoolbox here).
\let\qdissertation@orig@mainmatter\mainmatter
\renewcommand{\mainmatter}{%
  \setcounter{secnumdepth}{3}%
  \setcounter{tocdepth}{3}%
  \addtocontents{toc}{\protect\setcounter{tocdepth}{3}}%
  \qdissertation@orig@mainmatter
}
% Discourage \subsection and below in front matter (warn if used).
\let\qdissertation@orig@subsection\subsection
\renewcommand{\subsection}{%
  \if@mainmatter\else
    \PackageWarning{qdissertation}{Do not use \string\subsection\space in front matter; use \string\section\space only}%
  \fi
  \qdissertation@orig@subsection
}
\let\qdissertation@orig@subsubsection\subsubsection
\renewcommand{\subsubsection}{%
  \if@mainmatter\else
    \PackageWarning{qdissertation}{Do not use \string\subsubsection\space in front matter; use \string\section\space only}%
  \fi
  \qdissertation@orig@subsubsection
}

% ------------------------------------------------------------------------------
% Packages (required for class behaviour and layout)
% ------------------------------------------------------------------------------
\RequirePackage{iftex}
\ifPDFTeX
  \RequirePackage[T1]{fontenc}%
  \RequirePackage[utf8]{inputenc}%
  \RequirePackage{lmodern}% Latin Modern as default font when using pdfTeX
\fi

\RequirePackage{fix-cm}% Allow CM to scale to arbitrary sizes if used

\RequirePackage[a4paper,margin=3.0cm]{geometry}% Default margins for the class

% ------------------------------------------------------------------------------
% Float placement: relaxed so floats sit closer to first reference and full
% float pages are easier. Defaults are conservative (few floats per page, large
% text fraction), which can push figures/tables far away. We allow more floats per
% page and more of a page to be float area so the algorithm places them sooner.
% ------------------------------------------------------------------------------
\renewcommand{\topfraction}{0.9}        % max fraction of page for top floats (default 0.7)
\renewcommand{\bottomfraction}{0.7}     % max fraction for bottom floats (default 0.3)
\renewcommand{\textfraction}{0.05}      % min fraction that must be text (default 0.2)
\renewcommand{\floatpagefraction}{0.8}  % min fraction for a float-only page (default 0.5)
\setcounter{topnumber}{4}               % max floats at top of page (default 2)
\setcounter{bottomnumber}{3}            % max floats at bottom (default 1)
\setcounter{totalnumber}{6}             % max total floats on a text page (default 3)

\RequirePackage{graphicx}% \includegraphics for figures
\RequirePackage{amsmath,amsfonts,amssymb}% Standard math
\RequirePackage{xcolor}% Used for link colour (qdissertationlinkblue)
\RequirePackage{microtype}% Protrusion (and expansion under pdfTeX) for better typography
\RequirePackage{setspace}% \onehalfspacing
\RequirePackage[document]{ragged2e}% \RaggedRight for left-aligned paragraphs
\RequirePackage{etoolbox}% \pretocmd, \patchcmd, \ifstrempty, etc.

% When the .aux file is read at \begin{document}, the kernel sets \@writefile to
% \@gobbletwo, so \@writefile{lof}{...} etc.\ are discarded and .lof/.lot/.loa
% are never created. Patch so we write those to the list files; then
% \listoffigures etc.\ can read them and the lists appear.
\newwrite\tf@lof
\newwrite\tf@lot
\newwrite\tf@loa
\long\def\qdissertation@writelist#1#2{%
  \@ifundefined{qdissertation@opened@#1}{%
    \immediate\openout\csname tf@#1\endcsname\jobname.#1
    \expandafter\gdef\csname qdissertation@opened@#1\endcsname{}%
  }{}%
  \immediate\write\csname tf@#1\endcsname{\unexpanded{#2}}%
}
\def\qdissertation@write@lof#1{\qdissertation@writelist{lof}{#1}}
\def\qdissertation@write@lot#1{\qdissertation@writelist{lot}{#1}}
\def\qdissertation@write@loa#1{\qdissertation@writelist{loa}{#1}}
% Only lof/lot/loa get written to list files; toc and others are gobbled (kernel behaviour).
\long\def\qdissertation@writefile#1#2{%
  \edef\qdissertation@write@arg{#1}%
  \ifx\qdissertation@write@arg\qdissertation@lofstr
    \qdissertation@write@lof{#2}%
  \else
    \ifx\qdissertation@write@arg\qdissertation@lotstr
      \qdissertation@write@lot{#2}%
    \else
      \ifx\qdissertation@write@arg\qdissertation@loastr
        \qdissertation@write@loa{#2}%
      \else
        \@gobbletwo{#1}{#2}%
      \fi
    \fi
  \fi
}
\def\qdissertation@lofstr{lof}\def\qdissertation@lotstr{lot}\def\qdissertation@loastr{loa}
\patchcmd{\document}{\let\@writefile\@gobbletwo}{\let\@writefile\qdissertation@writefile}{}{}

% Citations: natbib with options matching class (harvard or numeric)
\ifqdissertation@cite@harvard
  \RequirePackage[authoryear,round,sort&compress,longnamesfirst]{natbib}%
  % Author-year style: (Author, 2000; Author & Coauthor, 2001)
  \bibpunct{(}{)}{;}{a}{,}{,}%
\else
  % Numeric, compressed: [1], [1,2], [1–3]
  \RequirePackage[numbers,sort&compress,square]{natbib}%
  \bibpunct{[}{]}{,}{n}{,}{,}%
\fi
\RequirePackage{xurl}% Allow line breaks in URLs
\RequirePackage{hyperref}% PDF links, bookmarks, and metadata
\ifPDFTeX
  \RequirePackage[hyphenbreaks]{breakurl}% Better URL breaking with pdfTeX
\fi

% Glossaries: if you define acronyms with \newacronym, a List of Acronyms is
% included in the front matter. Default style: long-short (first use: ``long (short)'',
% later: short). Build: pdflatex, then makeglossaries (or makeindex), then pdflatex again.
\RequirePackage[acronym,nomain,toc]{glossaries}% nomain: we only use acronyms, not the main glossary
\setacronymstyle{long-short}% First use: full form (abbreviation); later: abbreviation only
\makeglossaries
\newif\ifqdissertation@hasacronyms
\qdissertation@hasacronymsfalse
\pretocmd{\newacronym}{\global\qdissertation@hasacronymstrue}{}{}
% Acronym file: loaded automatically if it exists. Override with
% \renewcommand{\qdissertationacronymfile}{yourfile.tex} in the preamble.
\newcommand{\qdissertationacronymfile}{acronyms.tex}
\IfFileExists{\qdissertationacronymfile}{\input{\qdissertationacronymfile}}{}
\AtBeginDocument{\glsaddall}% Include all defined acronyms in the list

% Redirect bare \cite to \citep and emit a warning, so authors use \citep
% (parenthetical) or \citet (narrative) explicitly.
\renewcommand{\cite}{%
  \PackageWarning{qdissertation}{Use \string\citep\space or \string\citet\space instead of \string\cite}%
  \citep
}

\RequirePackage[font=small]{caption}% Caption font at least 11pt
\RequirePackage{textcomp}% \textcopyright for copyright page, \textdegree, etc.

% Link colour: used by hyperref and by our \href/\url overrides (no PDF border)
\definecolor{qdissertationlinkblue}{RGB}{0,0,120}

% ------------------------------------------------------------------------------
% Font configuration (depends on class options: mixed, sans, serif)
% ------------------------------------------------------------------------------
\ifPDFTeX
  \ifqdissertation@font@mixed
    \RequirePackage[default]{sourcesanspro}%
    \RequirePackage{newtxmath}%
    \renewcommand{\familydefault}{\sfdefault}%
  \fi
  \ifqdissertation@font@sans
    \RequirePackage[default]{sourcesanspro}%
    \renewcommand{\familydefault}{\sfdefault}%
  \fi
  \ifqdissertation@font@serif
    \RequirePackage{newtxtext}%
    \RequirePackage{newtxmath}%
  \fi
\else
  % XeLaTeX/LuaLaTeX: use fontspec; avoid scaling so 12pt is true document size
  \RequirePackage{fontspec}%
  \defaultfontfeatures{Ligatures=TeX}%
  \ifqdissertation@font@mixed
    \setmainfont{TeX Gyre Heros}%
    \setsansfont{TeX Gyre Heros}%
    \setmonofont{TeX Gyre Cursor}%
  \fi
  \ifqdissertation@font@sans
    \setmainfont{TeX Gyre Heros}%
    \setsansfont{TeX Gyre Heros}%
    \setmonofont{TeX Gyre Cursor}%
  \fi
  \ifqdissertation@font@serif
    \setmainfont{TeX Gyre Termes}%
    \setsansfont{TeX Gyre Heros}%
    \setmonofont{TeX Gyre Cursor}%
  \fi
\fi

% ------------------------------------------------------------------------------
% Layout defaults for the Qyber dissertation class
% ------------------------------------------------------------------------------
\ifqdissertation@onehalfspacing
  \onehalfspacing
\else
  \ifqdissertation@linespread
    \linespread{\qdissertation@linespreadval}%
  \else
    \singlespacing
  \fi
\fi
\RaggedRight
\emergencystretch=3em
\RequirePackage{parskip}

% At document start: ensure footnotes/captions stay at least 11pt (\small);
% if \license was set, load qdissertation-licenses.tex for full license text in the
% License chapter (optional; copy from package into your project).
\AtBeginDocument{%
  \renewcommand{\footnotesize}{\small}%
  \ifqdissertation@license
    \InputIfFileExists{qdissertation-licenses.tex}{}{}%
  \fi
}

\microtypesetup{final,protrusion=true,nopatch=footnote}%
\ifXeTeX\else \microtypesetup{expansion=true}\fi% Expansion only with pdfTeX

\hypersetup{
  unicode=true,
  breaklinks=true,
  colorlinks=true,
  linkcolor=qdissertationlinkblue,
  citecolor=qdissertationlinkblue,
  urlcolor=qdissertationlinkblue,
  filecolor=qdissertationlinkblue,
  menucolor=qdissertationlinkblue
}
% Override \href and \UrlFont so all links use qdissertationlinkblue (no box, just colour)
\let\qdissertation@orig@href\href
\renewcommand{\href}[2]{%
  \qdissertation@orig@href{#1}{%
    {\color{qdissertationlinkblue}#2}%
  }%
}

\def\UrlFont{\ttfamily\color{qdissertationlinkblue}}%

% ------------------------------------------------------------------------------
% Page style (headers and footers)
% ------------------------------------------------------------------------------

\RequirePackage{fancyhdr}

% Thin rule on plain pages; thick rule on chapter opening pages (behind chapter label)
\newlength{\qdissertation@headruleheight}
\newlength{\qdissertation@headruleheight@thick}
\setlength{\qdissertation@headruleheight}{0.4pt}
\setlength{\qdissertation@headruleheight@thick}{3.2pt}

% Increase headheight for the chapter bar; reduce top margin so layout stays correct
\setlength{\headheight}{32pt}
\addtolength{\topmargin}{-16pt}

% No header/footer or rules (e.g. title page, abstract)
\fancypagestyle{empty}{%
  \fancyhf{}%
  \renewcommand{\headrulewidth}{0pt}%
  \renewcommand{\footrulewidth}{0pt}%
}

% Running heads: page number; section/chapter title in main matter only; thin rule
\fancypagestyle{plain}{%
  \fancyhf{}%
  \ifqdissertation@twoside
    \fancyhead[LE,RO]{\thepage}%
    \if@mainmatter
      \fancyhead[LO,RE]{\slshape\leftmark}%
    \else
      \fancyhead[LO,RE]{}%
    \fi
  \else
    \fancyhead[R]{\thepage}%
    \if@mainmatter
      \fancyhead[L]{\slshape\leftmark}%
    \else
      \fancyhead[L]{}%
    \fi
  \fi
  \renewcommand{\headrulewidth}{\qdissertation@headruleheight}%
}

% Chapter opening page: page number and "Chapter N" / "Appendix A" in header with thick rule
\fancypagestyle{chapter}{%
  \fancyhf{}%
  \ifqdissertation@twoside
    \fancyhead[RO,LE]{\thepage}%
  \else
    \fancyhead[R]{\thepage}%
  \fi
  \renewcommand{\headrule}{%
    \begingroup
      \normalfont
      \setlength{\dimen0}{0pt}%
      \settowidth{\dimen0}{\Large\bfseries\ \MakeUppercase{\@chapapp}~\qdissertation@chapterlabel}%
      \vskip2pt
      \hrule\@height\qdissertation@headruleheight\@width\headwidth
      \vskip-\qdissertation@headruleheight
      \hbox to\headwidth{\hfill\vrule\@height\qdissertation@headruleheight@thick\@width\dimen0}%
      \hbox to\headwidth{\hfill\Large\bfseries \MakeUppercase{\@chapapp}~\qdissertation@chapterlabel}%
      \vskip-0.3\baselineskip
    \endgroup
  }%
  \renewcommand{\headrulewidth}{0pt}%
}

\pagestyle{plain}

% ------------------------------------------------------------------------------
% Chapter and appendix headings
% ------------------------------------------------------------------------------
% Main matter: "1. Title", "2. Title". Appendix: "A. Title", "B. Title".
% Front matter chapters (unnumbered) get no number. \qdissertation@chapterlabel is
% what appears in the header (number or appendix letter).
\def\@makechapterhead#1{%
  \vspace*{3\baselineskip}%
  {\noindent\Huge\bfseries
    \if@mainmatter
      \thechapter.\ %
    \else
      \ifqdissertation@inappendix
        \qdissertation@chapterletter.\ %
      \fi
    \fi
    #1\par}%
  \vspace{2\baselineskip}%
}
\def\@makeschapterhead#1{%
  \vspace*{3\baselineskip}%
  {\noindent\Huge\bfseries #1\par}%
  \vspace{2\baselineskip}%
}

% First page of unstarred chapters uses "chapter" style; starred chapters use "plain"
\newif\ifqdissertation@inappendix
\qdissertation@inappendixfalse
\newcommand{\qdissertation@chapterletter}{}
\def\qdissertation@chapterlabel{\ifqdissertation@inappendix \qdissertation@chapterletter \else \thechapter \fi}

% After \backmatter, chapters are appendices: numbering A, B, C and section numbers A.1, A.2, ...
\newcounter{qdissertation@appendixtoc@flag}
\let\qdissertation@orig@backmatter\backmatter
\renewcommand{\backmatter}{%
  \qdissertation@orig@backmatter
  \global\qdissertation@inappendixtrue
  \setcounter{chapter}{0}%
  \setcounter{section}{0}%
  \gdef\@chapapp{\appendixname}%
  \gdef\thechapter{\@Alph\c@chapter}%
  \gdef\thesection{\thechapter.\@arabic\c@section}%
  \gdef\thesubsection{\thesection.\@arabic\c@subsection}%
  \gdef\thesubsubsection{\thesubsection.\@arabic\c@subsubsection}%
  \gdef\theparagraph{\thesubsubsection.\@arabic\c@paragraph}%
  \gdef\thesubparagraph{\theparagraph.\@arabic\c@subparagraph}%
  \setcounter{secnumdepth}{3}%
  \setcounter{qdissertation@appendixtoc@flag}{0}%
}

\let\qdissertation@orig@appendix\appendix
\renewcommand{\appendix}{%
  \qdissertation@orig@appendix
  \global\qdissertation@inappendixtrue
}

% On each (unstarred) chapter: use "chapter" style on first page in main matter or
% appendix; otherwise "plain". Then switch to plain for following pages.
\pretocmd{\@chapter}{%
  \if@mainmatter
    \thispagestyle{chapter}%
  \else
    \ifqdissertation@inappendix
      \refstepcounter{chapter}%
      \xdef\qdissertation@chapterletter{\@Alph\c@chapter}%
      \global\advance\c@qdissertation@appendixtoc@flag\@ne
      \thispagestyle{chapter}%
    \else
      \thispagestyle{plain}%
    \fi
  \fi
  \pagestyle{plain}%
}{}{}

\pretocmd{\@schapter}{%
  \thispagestyle{plain}%
  \pagestyle{plain}%
}{}{}

% Standard book class omits \numberline for backmatter chapters, so appendix
% entries in the TOC would show no "A", "B". We wrap \addcontentsline and
% inject \numberline for appendix chapters so the TOC shows "A Title", "B Title".
\def\qdissertation@toc@name{toc}%
\def\qdissertation@level@chapter{chapter}%
\def\qdissertation@wrap@addcontentsline{%
  \let\qdissertation@orig@addcontentsline\addcontentsline
  \def\addcontentsline##1##2##3{%
    \edef\qdissertation@toc@arg{##1}%
    \edef\qdissertation@level@arg{##2}%
    \ifx\qdissertation@toc@arg\qdissertation@toc@name
      \ifx\qdissertation@level@arg\qdissertation@level@chapter
        \ifnum\c@qdissertation@appendixtoc@flag>\z@
          \global\advance\c@qdissertation@appendixtoc@flag\m@ne
          \qdissertation@orig@addcontentsline{##1}{##2}{\protect\numberline{\thechapter}##3}%
        \else
          \qdissertation@orig@addcontentsline{##1}{##2}{##3}%
        \fi
      \else
        \qdissertation@orig@addcontentsline{##1}{##2}{##3}%
      \fi
    \else
      \qdissertation@orig@addcontentsline{##1}{##2}{##3}%
    \fi
  }%
}
\AtBeginDocument{\qdissertation@wrap@addcontentsline}

% Put the bibliography into the TOC as a chapter
\patchcmd{\thebibliography}{\bibsection}{\bibsection\addcontentsline{toc}{chapter}{\bibname}}{}{}

% Supply \leftmark for running heads (chapter title or section number + title)
\renewcommand{\chaptermark}[1]{\markboth{#1}{}}
\renewcommand{\sectionmark}[1]{\markboth{\thesection\ #1}{}}
\renewcommand{\subsectionmark}[1]{}

% ------------------------------------------------------------------------------
% Metadata and title page
% ------------------------------------------------------------------------------
% User commands store values in internal macros used by \maketitlepage and \bib

\newcommand{\qdissertation@title}{}
\newcommand{\qdissertation@author}{}
\newcommand{\qdissertation@degree}{}
\newcommand{\qdissertation@university}{Your University}
\newcommand{\qdissertation@date}{\today}

\renewcommand{\title}[1]{\gdef\qdissertation@title{#1}}
\renewcommand{\author}[1]{\gdef\qdissertation@author{#1}}
\newcommand{\degree}[1]{\gdef\qdissertation@degree{#1}}
\newcommand{\university}[1]{\gdef\qdissertation@university{#1}}
\renewcommand{\date}[1]{\gdef\qdissertation@date{#1}}

% ------------------------------------------------------------------------------
% License and copyright (SPDX)
% ------------------------------------------------------------------------------
% \license{SPDX-ID} enables a copyright page after the abstract and a License
% chapter before the bibliography. Optional: \copyrightholder, \licenseyear.

\newif\ifqdissertation@license
\qdissertation@licensefalse
\gdef\qdissertation@licenseid{}%
\gdef\qdissertation@copyrightholder{}%
\gdef\qdissertation@licenseyear{}%

\newcommand{\license}[1]{%
  \qdissertation@licensetrue
  \gdef\qdissertation@licenseid{#1}%
}
\newcommand{\copyrightholder}[1]{\gdef\qdissertation@copyrightholder{#1}}
\newcommand{\licenseyear}[1]{\gdef\qdissertation@licenseyear{#1}}

% Map SPDX identifier to {display name, URL}. Unknown IDs get generic spdx.org link.
\def\qdissertation@setlicfrompair#1{\expandafter\qdissertation@setlicfrompair@aux#1}
\def\qdissertation@setlicfrompair@aux#1#2{\gdef\qdissertation@lic@name{#1}\gdef\qdissertation@lic@url{#2}}
\expandafter\def\csname qdissertation@lic@MIT\endcsname{{MIT License}{https://spdx.org/licenses/MIT.html}}
\expandafter\def\csname qdissertation@lic@Apache-2.0\endcsname{{Apache License 2.0}{https://www.apache.org/licenses/LICENSE-2.0}}
\expandafter\def\csname qdissertation@lic@GPL-3.0-only\endcsname{{GNU GPL License v3.0 only}{https://spdx.org/licenses/GPL-3.0-only.html}}
\expandafter\def\csname qdissertation@lic@GPL-3.0-or-later\endcsname{{GNU GPL License v3.0 or later}{https://spdx.org/licenses/GPL-3.0-or-later.html}}
\expandafter\def\csname qdissertation@lic@AGPL-3.0-only\endcsname{{GNU AGPL License v3.0 only}{https://spdx.org/licenses/AGPL-3.0-only.html}}
\expandafter\def\csname qdissertation@lic@AGPL-3.0-or-later\endcsname{{GNU AGPL License v3.0 or later}{https://spdx.org/licenses/AGPL-3.0-or-later.html}}
\expandafter\def\csname qdissertation@lic@GFDL-1.3\endcsname{{GNU Free Documentation License 1.3}{https://www.gnu.org/licenses/fdl-1.3.html}}
\expandafter\def\csname qdissertation@lic@CC-BY-4.0\endcsname{{Creative Commons Attribution License 4.0}{https://creativecommons.org/licenses/by/4.0/legalcode}}
\expandafter\def\csname qdissertation@lic@CC-BY-SA-4.0\endcsname{{Creative Commons Attribution-ShareAlike License 4.0}{https://creativecommons.org/licenses/by-sa/4.0/legalcode}}
\expandafter\def\csname qdissertation@lic@CC-BY-NC-4.0\endcsname{{Creative Commons Attribution-NonCommercial License 4.0}{https://creativecommons.org/licenses/by-nc/4.0/legalcode}}
\expandafter\def\csname qdissertation@lic@CC-BY-NC-SA-4.0\endcsname{{Creative Commons Attribution-NonCommercial-ShareAlike License 4.0}{https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode}}
\expandafter\def\csname qdissertation@lic@CC-BY-NC-ND-4.0\endcsname{{Creative Commons Attribution-NonCommercial-NoDerivatives License 4.0}{https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode}}
\expandafter\def\csname qdissertation@lic@CC-BY-ND-4.0\endcsname{{Creative Commons Attribution-NoDerivatives License 4.0}{https://creativecommons.org/licenses/by-nd/4.0/legalcode}}
\expandafter\def\csname qdissertation@lic@CC0-1.0\endcsname{{CC0 1.0 Universal}{https://creativecommons.org/publicdomain/zero/1.0/legalcode}}
\expandafter\def\csname qdissertation@lic@BSD-2-Clause\endcsname{{BSD 2-Clause ``Simplified'' License}{https://spdx.org/licenses/BSD-2-Clause.html}}
\expandafter\def\csname qdissertation@lic@BSD-3-Clause\endcsname{{BSD 3-Clause ``New'' or ``Revised'' License}{https://spdx.org/licenses/BSD-3-Clause.html}}
\expandafter\def\csname qdissertation@lic@LPPL-1.3c\endcsname{{LaTeX Project Public License 1.3c}{https://www.latex-project.org/lppl/lppl-1-3c.html}}

% Resolve current \qdissertation@licenseid to display name and URL (from table above or generic)
\newcommand{\qdissertation@resolvelicense}{%
  \edef\qdissertation@lic@curid{\qdissertation@licenseid}%
  \edef\qdissertation@lic@cstest{qdissertation@lic@\qdissertation@lic@curid}%
  \expandafter\@ifundefined\expandafter{\qdissertation@lic@cstest}{%
    \gdef\qdissertation@lic@name{SPDX: \qdissertation@licenseid}%
    \gdef\qdissertation@lic@url{https://spdx.org/licenses/\qdissertation@licenseid.html}%
  }{%
    \expandafter\qdissertation@setlicfrompair\csname qdissertation@lic@\qdissertation@lic@curid\endcsname
  }%
}

% Copyright page: shown after the abstract when \license{...} was set
\newcommand{\qdissertation@copyrightpage}{%
  \clearpage
  \thispagestyle{empty}%
  \qdissertation@resolvelicense
  \vfill
  \begin{center}
    \ \vfill
    Copyright\ \textcopyright\ \ifstrempty{\qdissertation@licenseyear}{\number\year}{\qdissertation@licenseyear}\ %
    \ifstrempty{\qdissertation@copyrightholder}{\qdissertation@author}{\qdissertation@copyrightholder}\par
    \vspace{1ex}
    This work is licensed under the \qdissertation@lic@name.\\{\ttfamily SPDX-License-Identifier: \qdissertation@licenseid}\\
    Full text: \url{\qdissertation@lic@url}
  \end{center}
  \cleardoublepage
}

\newcommand{\maketitlepage}{%
  \begin{titlepage}
    \thispagestyle{empty}% No page number on title page
    \begin{center}
      \vspace*{3ex}
      {\Huge\bfseries \qdissertation@title\par}
      \vfill
      {\LARGE \qdissertation@author\par}
      \vfill\vfill\vfill
      % Only show the degree sentence if a non-empty degree has been set
      \ifstrempty{\qdissertation@degree}{}{%
        {\Large A dissertation submitted for the degree of\par}
        {\Large\bfseries \qdissertation@degree\par}%
        \vspace{4ex}%
      }%
      \vspace{8ex}
      {\Large \qdissertation@university\par}
      \vspace{2ex}
      {\Large \qdissertation@date\par}
    \end{center}
  \end{titlepage}
}

% Full front-matter sequence: title page, optional copyright page, abstract,
% then \frontlists (TOC, List of Figures, List of Tables, List of Algorithms, List of Acronyms)
\renewcommand{\maketitle}[1]{%
  \maketitlepage
  \ifqdissertation@license
    \qdissertation@copyrightpage
  \else
    \cleardoublepage
  \fi
  \begingroup
    \chapter*{Abstract}%
    \addcontentsline{toc}{chapter}{Abstract}%
    #1%
  \endgroup
  \cleardoublepage
  \frontlists
}

% ------------------------------------------------------------------------------
% Front matter: TOC and optional lists of figures, tables, algorithms
% ------------------------------------------------------------------------------
% We scan .lof/.lot/.loa (populated when .aux was read via our \@writefile patch)
% and only output each list if it has at least one entry.

\newif\ifqdissertation@haslof
\newif\ifqdissertation@haslot
\newif\ifqdissertation@hasloa

% Standard \contentsline is 3-arg; hyperref uses 4. Consume 3 and optionally gobble 4th.
\newcommand{\qdissertation@checklof}{%
  \qdissertation@hasloffalse
  \begingroup
    \makeatletter
    \let\addvspace\@gobble
    \def\contentsline##1##2##3{%
      \global\qdissertation@hasloftrue
      \@ifnextchar\bgroup{\@gobble}{}%
    }%
    \IfFileExists{\jobname.lof}{\input{\jobname.lof}}{}%
  \endgroup
}
\newcommand{\qdissertation@checklot}{%
  \qdissertation@haslotfalse
  \begingroup
    \makeatletter
    \let\addvspace\@gobble
    \def\contentsline##1##2##3{%
      \global\qdissertation@haslottrue
      \@ifnextchar\bgroup{\@gobble}{}%
    }%
    \IfFileExists{\jobname.lot}{\input{\jobname.lot}}{}%
  \endgroup
}
\newcommand{\qdissertation@checkloa}{%
  \qdissertation@hasloafalse
  \begingroup
    \makeatletter
    \let\addvspace\@gobble
    \def\contentsline##1##2##3{%
      \global\qdissertation@hasloatrue
      \@ifnextchar\bgroup{\@gobble}{}%
    }%
    \IfFileExists{\jobname.loa}{\input{\jobname.loa}}{}%
  \endgroup
}

\newcommand{\frontlists}{%
  \tableofcontents
  \cleardoublepage
  \qdissertation@checklof
  \ifqdissertation@haslof
    \listoffigures
    \addcontentsline{toc}{chapter}{List of Figures}%
    \cleardoublepage
  \fi
  \qdissertation@checklot
  \ifqdissertation@haslot
    \listoftables
    \addcontentsline{toc}{chapter}{List of Tables}%
    \cleardoublepage
  \fi
  \qdissertation@checkloa
  \ifqdissertation@hasloa
    \listofalgorithms
    \addcontentsline{toc}{chapter}{List of Algorithms}%
    \cleardoublepage
  \fi
  \ifqdissertation@hasacronyms
    \printglossary[type=\acronymtype]
    \cleardoublepage
  \fi
}

% ------------------------------------------------------------------------------
% Bibliography
% ------------------------------------------------------------------------------
% \bib{basename} sets bibliography style (harvard -> agsm, numeric -> plainnat),
% optionally prints the License chapter (with full text if qdissertation-licenses.tex
% defined it for this SPDX ID), then \bibliography{basename}.
\newcommand{\bib}[1]{%
  \ifqdissertation@cite@harvard
    \bibliographystyle{agsm}%
  \else
    \bibliographystyle{plainnat}%
  \fi
  \ifqdissertation@license
    \qdissertation@resolvelicense
    \chapter*{License}\label{sec:license}%
    \addcontentsline{toc}{chapter}{License}%
    This work is licensed under the \qdissertation@lic@name.\\{\ttfamily SPDX-License-Identifier: \qdissertation@licenseid}\par
    \vspace{1ex}
    \edef\qdissertation@lic@textcs{qdissertation@licensetext@\qdissertation@licenseid}%
    \expandafter\@ifundefined\expandafter{\qdissertation@lic@textcs}{%
      The full license text is available at: \url{\qdissertation@lic@url}\par
    }{%
      \small
      \@nameuse{\qdissertation@lic@textcs}%
    }%
    \vspace{2\baselineskip}%
  \fi
  \bibliography{#1}%
}

\makeatother
