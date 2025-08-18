# 🚢 Karmada + vCluster で実現する仮想的なマルチクラスタ運用環境

## はじめに

近年、複数の Kubernetes クラスタを運用するためのベストプラクティスが話題となり、それに伴う形で MCO (Multi-cluster Orchestrator) をはじめとしたマルチクラスタオーケストレーションツールが登場している。  
代表的なツールとして以下のものがある。  

  - [Karmada](https://karmada.io/)  
  - [kro](https://kro.run/)  
  - [GKE Multi-cluster Orchestrator](https://cloud.google.com/blog/products/containers-kubernetes/multi-cluster-orchestrator-for-cross-region-kubernetes-workloads?hl=en)  

## Karmada

### Karmada とは？

![karmada-component](https://karmada.io/assets/images/components-9bbbf90a2242f49a418e53615f1b18be.png)

Karmada (Kubernetes Armada) は、アプリケーション自体に変更を加えることなく、複数の Kubernetes クラスタやクラウドにまたがってクラウドネイティブアプリケーションを実行することを可能にする、オープンソースのマルチクラスタKubernetes管理システムである。  
Cloud Native Computing Foundation (CNCF) のインキュベーションプロジェクトでもある。  
その中核は、 Kubernetes ネイティブな API を利用してマルチクラスタ環境を抽象化し、一元的にオーケストレーション (編成・管理) する点にある。  
利用者は、既存の Kubernetes ツール (例: kubectl) や API の知識をそのまま活用して、単一のコントロールプレーンから多数のクラスタを操作できる。  
Karmada は、このマルチクラスタ管理を実現するために、独自のカスタムリソース定義 (CRD) 群を Kubernetes API サーバーに導入する。  
利用者が PropagationPolicy や OverridePolicy といった Karmada の CRD を含むマニフェストを Karmada のコントロールプレーンに適用すると、 Karmada のコントローラーがその内容を解釈し、どのアプリケーションをどのクラスタに、どのようにデプロイするかを決定して実行する。

**Karmada の主な目的と特徴**  

- Kubernetes ネイティブ API との互換性  
シングルクラスタからマルチクラスタへの移行に際して、アプリケーションのコードやデプロイマニフェストを大幅に変更する必要がない。  
既存の CI/CD パイプラインやツールチェーンとの親和性が高い。  
- 高度なスケジューリングポリシー  
地理的な冗長性 (Geo Redundant) 、アクティブ-アクティブ、リモートDR (災害復旧) といったシナリオに対応するためのポリシーが組み込まれている。  
クラスタアフィニティ (特定の特性を持つクラスタに配置) や、複数クラスタ間でのワークロードの分散・再配置 (Splitting/Rebalancing) を柔軟に制御できる。
- ベンダーロックインの回避  
主要なパブリッククラウドやオンプレミス、エッジ環境にあるクラスタを区別なく管理できる。  
これにより、特定のクラウドベンダーの独自オーケストレーションツールに縛られることなく、クラスタ間でワークロードを自由に移行させることが可能となる。
- 中央集権的な管理と高可用性  
場所を問わず全てのクラスタを一元的に管理する。  
また、複数クラスタにまたがってアプリケーションを自動でスケールさせたり、一部のクラスタで障害が発生した際に正常なクラスタへ自動的にフェイルオーバーさせたりする機能を持つ。

### [karmadactl をインストールする](https://karmada.io/docs/installation/install-cli-tools/#install-karmadactl)

- [Krew](https://krew.sigs.k8s.io/) を使って Karmada プラグインをインストールする

  ```shell
  kubectl krew install karmada
  ```

  - インストール後は以下のコマンドで利用可能

    ```shell
    kubectl karmada
    ```
  
- クラスタへKarmadaをインストールする

  ```shell
  kubectl karmada init
  ```

### Helm を使用してインストールする

- 以下のコマンドを実行する

## vCluster

### vCluster とは？

vCluster、vCluster Platform、vNodeは、いずれもKubernetes環境におけるマルチテナンシーとリソース管理を効率化・強化するためのツールであるが、それぞれ異なる役割と機能を持つ。

**vCluster**  

vCluster は、既存のKubernetesクラスタ内に仮想的な Kubernetes クラスタ (Virtual Cluster) を作成するためのオープンソースのソリューションである。  
物理的なクラスタを追加で構築することなく、開発、テスト、 CI/CD などの用途ごとに、完全に独立した API サーバーとコントロールプレーンを持つ Kubernetes 環境を迅速に提供できる。  
これにより、インフラコストを削減しつつ、各チームやワークロードにセキュアで分離された環境を払い出すことが可能となる。
vCluster は、ワークロードの分離レベルに応じて複数のテナンシーモデルを提供する。

- **Shared Nodes**:  
複数の仮想クラスタがホストクラスタのノードを共有する最もシンプルなモデル。
- **Dedicated Nodes**:  
特定の仮想クラスタが、ホストクラスタ内の特定のノード群を専有するモデル。
- **Private Nodes**:  
仮想クラスタごとに完全に独立したホストクラスタとノードを割り当てる、最も分離レベルが高いモデル。

これらのモデルにより、セキュリティ、コスト、パフォーマンスの要件に応じた柔軟な環境構築が実現する。

**vCluster Platform**  

vCluster Platform は、複数の物理・仮想 Kubernetes クラスタにまたがる vCluster インスタンス群と、それを利用するユーザーを一元的に管理するための商用プラットフォームである。  
vCluster 単体ではコマンドラインでの操作が基本となるが、vCluster Platform は Web ベースの UI (Single Pane of Glass) を提供し、以下のような高度な管理機能を実現する。

- **プロジェクト管理**:  
チームや部門単位でリソースをグループ化し、役割ベースのアクセス制御 (RBAC) を適用する。
- **クラスタ管理**:  
複数の物理クラスタをプラットフォームに接続し、集中的に管理する。
- **コスト削減機能**:
  - **スリープモード**:  
  仮想クラスタの一定期間利用されていない仮想クラスタやnamespace のリソース (Pod) を自動的に停止 (レプリカ数を0に設定) し、リソース消費を抑える。
  - **自動削除**:  
  非アクティブな仮想クラスタを自動的に削除する。
- **アプリケーション管理**:  
Helm チャートなどで定義されたアプリケーションをカタログ化し、ユーザーがセルフサービスでデプロイできるようにする。

**vNode**  

vNode は、Linux カーネルのユーザーネームスペースや seccomp フィルターといった機能を活用し、コンテナワークロード間に強力な分離を提供するマルチテナンシーコンテナランタイムである。  
KVM のような完全な仮想化技術に頼らず、軽量なサンドボックス環境を構築することで、コンテナをホスト OS から安全に隔離する。  
これにより、以下のような利点が生まれる。

- **デフォルトでRootless**:  
コンテナはサンドボックス内で非 root ユーザーとして実行され、権限昇格のリスクを大幅に低減する。
- **特権機能の安全な利用**:  
Docker-in-Docker や `hostPID` , `hostNetwork` といった、通常はセキュリティリスクの高い特権的な操作を、ホストや他のコンテナに影響を与えることなく安全に実行できる。
- **高いパフォーマンス**:  
仮想化によるオーバーヘッドがほとんどなく、ネイティブに近い速度でコンテナを実行できる。

vNode は Kubernetes の RuntimeClass として統合され、特に vCluster と組み合わせて利用することで、仮想クラスタ内で実行される特権コンテナに対して、さらなるセキュリティレイヤーを追加する役割を果たす。  
利用には vCluster Platform のライセンスが必要である。

---

| 項目 | vCluster | vCluster Platform | vNode |
| :--- | :--- | :--- | :--- |
| **役割** | 仮想Kubernetesクラスタの**作成・実行** | 複数のvClusterとユーザーの**一元管理** | 強力な分離を提供する**コンテナランタイム** |
| **主な機能** | 仮想コントロールプレーン・複数のテナンシーモデル・APIレベルの分離 | GUIによる統合管理・RBAC、プロジェクト管理・コスト削減 (スリープモード等) ・アプリカタログ | ユーザーネームスペースによる分離・デフォルトでRootless実行・特権コンテナの安全な実行 |
| **動作レイヤー** | Kubernetesクラスタ内 (**仮想化レイヤー**)  | 管理・オーケストレーションレイヤー | ノード上 (**コンテナランタイムレイヤー**)  |
| **提供形態** | オープンソース | 商用製品 | 商用製品 (要Platformライセンス)  |
| **関係性** | Platformで管理され、vNodeをランタイムとして利用できる**基礎単位**。 | vClusterやvNodeを管理する**上位プラットフォーム**。 | vCluster内のワークロードを保護する**追加のセキュリティレイヤー**。 |

### [vCluster CLI をインストールする](http://vcluster.com/docs/platform/install/quick-start-guide)

- Homebrew を使って vCluster をインストールする  

  ```shell
  brew install loft-sh/tap/vcluster-experimental
  ```

### vCluster CLI 基本操作

- 仮想クラスタの作成 (--connect=false を追加するとクラスタ作成後に kube context を変更しない)
  
  ```shell
  vcluster create {{ cluster-name }} --namespace {{ namespace }} [--connect=false]
  ```

- 既存仮想クラスターの設定更新
  
  ```shell
  vcluster create --upgrade {{ cluster-name }} -n {{ namespace }} -f vcluster.yaml
  ```

  - k3s 以外の distro を指定する

    ```shell
    vcluster create --upgrade {{ cluster-name }} -n {{ namespace }} --distro k0s
    ```

- 仮想クラスタへの接続

  ```shell
  vcluster connect {{ cluster-name }} --namespace {{ namespace }}
  ```

- 接続中の仮想クラスターへの接続を切断してホストクラスターに戻る
  
  ```shell
  vcluster disconnect
  ```

- 仮想クラスター一覧

  ```shell
  vcluster list
  ```

- 仮想クラスター削除
  
  ```shell
  vcluster delete {{ cluster-name }} --namespace {{ namespace }}
  ```

## 検証

### kind クラスタを作成する

- kind コマンドを実行してクラスタを構築する

  ```shell
  kind create cluster --config config/kind-config.yaml
  ```

- kubectl コマンドで作成したクラスタを確認する  
  今回はワーカノードを2つ作成する  

  ```shell
  $ kubectl get nodes
  NAME                 STATUS     ROLES           AGE   VERSION
  kind-control-plane   NotReady   control-plane   70s   v1.33.1
  kind-worker          NotReady   <none>          60s   v1.33.1
  kind-worker2         NotReady   <none>          60s   v1.33.1
  ```

### vCluster をデプロイする

- vCluster を kind で作成した Kubernetes クラスタにデプロイする

  ```shell
  vcluster create my-vcluster --namespace team-x --values vcluster.yaml
  ```
