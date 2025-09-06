; ModuleID = 'flat.c'
source_filename = "flat.c"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf"

%struct.anon.7 = type { ptr, ptr }
%struct.packet_t = type { %struct.in6_addr, %struct.in6_addr, i16, i16, i8, i8, i8, i8, i64 }
%struct.in6_addr = type { %union.anon.5 }
%union.anon.5 = type { [4 x i32] }

@_license = dso_local global [13 x i8] c"Dual MIT/GPL\00", section "license", align 1, !dbg !0
@flat.____fmt = internal constant [15 x i8] c"Got a Packet!\0A\00", align 1, !dbg !46
@pipe = dso_local global %struct.anon.7 zeroinitializer, section ".maps", align 8, !dbg !325
@llvm.compiler.used = appending global [3 x ptr] [ptr @_license, ptr @flat, ptr @pipe], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local noundef i32 @flat(ptr noundef %0) #0 section "tc" !dbg !48 {
  %2 = alloca %struct.packet_t, align 8, !DIAssignID !348
    #dbg_assign(i1 undef, !273, !DIExpression(), !348, ptr %2, !DIExpression(), !349)
    #dbg_value(ptr %0, !157, !DIExpression(), !349)
  %3 = tail call i64 (ptr, i32, ...) inttoptr (i64 6 to ptr)(ptr noundef nonnull @flat.____fmt, i32 noundef 15) #3, !dbg !350
  %4 = tail call i64 inttoptr (i64 39 to ptr)(ptr noundef %0, i32 noundef 0) #3, !dbg !352
  %5 = icmp slt i64 %4, 0, !dbg !354
  br i1 %5, label %74, label %6, !dbg !355

6:                                                ; preds = %1
  %7 = getelementptr inbounds i8, ptr %0, i64 4, !dbg !356
  %8 = load i32, ptr %7, align 4, !dbg !356, !tbaa !358
  %9 = add i32 %8, -1, !dbg !364
  %10 = icmp ult i32 %9, 2, !dbg !364
  br i1 %10, label %74, label %11, !dbg !364

11:                                               ; preds = %6
  %12 = getelementptr inbounds i8, ptr %0, i64 76, !dbg !365
  %13 = load i32, ptr %12, align 4, !dbg !365, !tbaa !366
  %14 = zext i32 %13 to i64, !dbg !367
  %15 = inttoptr i64 %14 to ptr, !dbg !368
    #dbg_value(ptr %15, !158, !DIExpression(), !349)
  %16 = getelementptr inbounds i8, ptr %0, i64 80, !dbg !369
  %17 = load i32, ptr %16, align 8, !dbg !369, !tbaa !370
  %18 = zext i32 %17 to i64, !dbg !371
  %19 = inttoptr i64 %18 to ptr, !dbg !372
    #dbg_value(ptr %19, !159, !DIExpression(), !349)
  %20 = getelementptr inbounds i8, ptr %15, i64 14, !dbg !373
  %21 = icmp ugt ptr %20, %19, !dbg !375
  br i1 %21, label %74, label %22, !dbg !376

22:                                               ; preds = %11
    #dbg_value(ptr %15, !160, !DIExpression(), !349)
  call void @llvm.lifetime.start.p0(i64 48, ptr nonnull %2) #3, !dbg !377
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(48) %2, i8 0, i64 48, i1 false), !dbg !378, !DIAssignID !379
    #dbg_assign(i8 0, !273, !DIExpression(), !379, ptr %2, !DIExpression(), !349)
    #dbg_value(i32 0, !291, !DIExpression(), !349)
  %23 = getelementptr inbounds i8, ptr %15, i64 12, !dbg !380
  %24 = load i16, ptr %23, align 1, !dbg !380, !tbaa !381
  %25 = icmp eq i16 %24, 8, !dbg !384
  br i1 %25, label %26, label %73, !dbg !384

26:                                               ; preds = %22
    #dbg_value(i32 34, !291, !DIExpression(), !349)
  %27 = getelementptr inbounds i8, ptr %15, i64 34, !dbg !385
  %28 = icmp ugt ptr %27, %19, !dbg !388
  br i1 %28, label %73, label %29, !dbg !389

29:                                               ; preds = %26
    #dbg_value(ptr %20, !171, !DIExpression(), !349)
  %30 = getelementptr inbounds i8, ptr %15, i64 23, !dbg !390
  %31 = load i8, ptr %30, align 1, !dbg !390, !tbaa !392
  switch i8 %31, label %73 [
    i8 6, label %32
    i8 17, label %32
  ], !dbg !394

32:                                               ; preds = %29, %29
  %33 = getelementptr inbounds i8, ptr %15, i64 26, !dbg !395
  %34 = load i32, ptr %33, align 4, !dbg !395, !tbaa !396
  %35 = getelementptr inbounds i8, ptr %2, i64 12, !dbg !397
  store i32 %34, ptr %35, align 4, !dbg !398, !tbaa !396, !DIAssignID !399
    #dbg_assign(i32 %34, !273, !DIExpression(DW_OP_LLVM_fragment, 96, 32), !399, ptr %35, !DIExpression(), !349)
  %36 = getelementptr inbounds i8, ptr %15, i64 30, !dbg !400
  %37 = load i32, ptr %36, align 4, !dbg !400, !tbaa !396
  %38 = getelementptr inbounds i8, ptr %2, i64 28, !dbg !401
  store i32 %37, ptr %38, align 4, !dbg !402, !tbaa !396, !DIAssignID !403
    #dbg_assign(i32 %37, !273, !DIExpression(DW_OP_LLVM_fragment, 224, 32), !403, ptr %38, !DIExpression(), !349)
  %39 = getelementptr inbounds i8, ptr %2, i64 20, !dbg !404
  store i32 65535, ptr %39, align 4, !dbg !405, !tbaa !396, !DIAssignID !406
    #dbg_assign(i32 65535, !273, !DIExpression(DW_OP_LLVM_fragment, 160, 32), !406, ptr %39, !DIExpression(), !349)
  %40 = getelementptr inbounds i8, ptr %2, i64 36, !dbg !407
  store i32 65535, ptr %40, align 4, !dbg !408, !tbaa !396, !DIAssignID !409
    #dbg_assign(i32 65535, !273, !DIExpression(DW_OP_LLVM_fragment, 288, 32), !409, ptr %40, !DIExpression(), !349)
  store i8 %31, ptr %40, align 4, !dbg !410, !tbaa !411, !DIAssignID !416
    #dbg_assign(i8 %31, !273, !DIExpression(DW_OP_LLVM_fragment, 288, 8), !416, ptr %40, !DIExpression(), !349)
  %41 = getelementptr inbounds i8, ptr %15, i64 22, !dbg !417
  %42 = load i8, ptr %41, align 4, !dbg !417, !tbaa !418
  %43 = getelementptr inbounds i8, ptr %2, i64 37, !dbg !419
  store i8 %42, ptr %43, align 1, !dbg !420, !tbaa !421, !DIAssignID !422
    #dbg_assign(i8 %42, !273, !DIExpression(DW_OP_LLVM_fragment, 296, 8), !422, ptr %43, !DIExpression(), !349)
    #dbg_value(i32 34, !291, !DIExpression(), !349)
  %44 = getelementptr inbounds i8, ptr %15, i64 54, !dbg !423
  %45 = icmp ugt ptr %44, %19, !dbg !425
  br i1 %45, label %73, label %46, !dbg !426

46:                                               ; preds = %32
  switch i8 %31, label %73 [
    i8 6, label %47
    i8 17, label %63
  ], !dbg !427

47:                                               ; preds = %46
    #dbg_value(ptr %27, !242, !DIExpression(), !349)
  %48 = getelementptr inbounds i8, ptr %15, i64 46, !dbg !428
  %49 = load i16, ptr %48, align 4, !dbg !428
  %50 = and i16 %49, 512, !dbg !431
  %51 = icmp eq i16 %50, 0, !dbg !431
  br i1 %51, label %73, label %52, !dbg !432

52:                                               ; preds = %47
  %53 = load i16, ptr %27, align 4, !dbg !433, !tbaa !435
  %54 = getelementptr inbounds i8, ptr %2, i64 32, !dbg !437
  store i16 %53, ptr %54, align 8, !dbg !438, !tbaa !439, !DIAssignID !440
    #dbg_assign(i16 %53, !273, !DIExpression(DW_OP_LLVM_fragment, 256, 16), !440, ptr %54, !DIExpression(), !349)
  %55 = getelementptr inbounds i8, ptr %15, i64 36, !dbg !441
  %56 = load i16, ptr %55, align 2, !dbg !441, !tbaa !442
  %57 = getelementptr inbounds i8, ptr %2, i64 34, !dbg !443
  store i16 %56, ptr %57, align 2, !dbg !444, !tbaa !445, !DIAssignID !446
    #dbg_assign(i16 %56, !273, !DIExpression(DW_OP_LLVM_fragment, 272, 16), !446, ptr %57, !DIExpression(), !349)
  %58 = getelementptr inbounds i8, ptr %2, i64 38, !dbg !447
  store i8 1, ptr %58, align 2, !dbg !448, !tbaa !449, !DIAssignID !450
    #dbg_assign(i8 1, !273, !DIExpression(DW_OP_LLVM_fragment, 304, 8), !450, ptr %58, !DIExpression(), !349)
  %59 = getelementptr inbounds i8, ptr %2, i64 39, !dbg !451
  %60 = lshr i16 %49, 12, !dbg !452
  %61 = trunc nuw nsw i16 %60 to i8, !dbg !452
  %62 = and i8 %61, 1, !dbg !452
  store i8 %62, ptr %59, align 1, !dbg !452, !tbaa !453, !DIAssignID !454
    #dbg_assign(i8 %62, !273, !DIExpression(DW_OP_LLVM_fragment, 312, 8), !454, ptr %59, !DIExpression(), !349)
    #dbg_assign(i64 %70, !273, !DIExpression(DW_OP_LLVM_fragment, 320, 64), !455, ptr %71, !DIExpression(), !349)
  br label %69, !dbg !456

63:                                               ; preds = %46
    #dbg_value(ptr %27, !264, !DIExpression(), !349)
  %64 = load i16, ptr %27, align 2, !dbg !457, !tbaa !458
  %65 = getelementptr inbounds i8, ptr %2, i64 32, !dbg !460
  store i16 %64, ptr %65, align 8, !dbg !461, !tbaa !439, !DIAssignID !462
    #dbg_assign(i16 %64, !273, !DIExpression(DW_OP_LLVM_fragment, 256, 16), !462, ptr %65, !DIExpression(), !349)
  %66 = getelementptr inbounds i8, ptr %15, i64 36, !dbg !463
  %67 = load i16, ptr %66, align 2, !dbg !463, !tbaa !464
  %68 = getelementptr inbounds i8, ptr %2, i64 34, !dbg !465
  store i16 %67, ptr %68, align 2, !dbg !466, !tbaa !445, !DIAssignID !467
    #dbg_assign(i16 %67, !273, !DIExpression(DW_OP_LLVM_fragment, 272, 16), !467, ptr %68, !DIExpression(), !349)
    #dbg_assign(i64 %70, !273, !DIExpression(DW_OP_LLVM_fragment, 320, 64), !455, ptr %71, !DIExpression(), !349)
  br label %69, !dbg !468

69:                                               ; preds = %52, %63
  %70 = tail call i64 inttoptr (i64 5 to ptr)() #3, !dbg !469
  %71 = getelementptr inbounds i8, ptr %2, i64 40, !dbg !469
  store i64 %70, ptr %71, align 8, !dbg !469, !tbaa !470, !DIAssignID !455
  %72 = call i64 inttoptr (i64 130 to ptr)(ptr noundef nonnull @pipe, ptr noundef nonnull %2, i64 noundef 48, i64 noundef 0) #3, !dbg !469
  br label %73, !dbg !471

73:                                               ; preds = %69, %22, %47, %46, %32, %29, %26
  call void @llvm.lifetime.end.p0(i64 48, ptr nonnull %2) #3, !dbg !471
  br label %74

74:                                               ; preds = %6, %73, %11, %1
  ret i32 0, !dbg !471
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

attributes #0 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #3 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!342, !343, !344, !345, !346}
!llvm.ident = !{!347}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 23, type: !339, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C11, file: !3, producer: "Ubuntu clang version 19.1.1 (1ubuntu1)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !39, globals: !45, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "flat.c", directory: "/Users/cassamajor/code/xcnf/examples/flow/bytecode", checksumkind: CSK_MD5, checksum: "99f800c18d1aa29b638a59cb4b11d792")
!4 = !{!5}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, file: !6, line: 29, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "/usr/include/linux/in.h", directory: "", checksumkind: CSK_MD5, checksum: "9c2bb8c4aeb4064bd816bf98027ba7c1")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10, !11, !12, !13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38}
!9 = !DIEnumerator(name: "IPPROTO_IP", value: 0)
!10 = !DIEnumerator(name: "IPPROTO_ICMP", value: 1)
!11 = !DIEnumerator(name: "IPPROTO_IGMP", value: 2)
!12 = !DIEnumerator(name: "IPPROTO_IPIP", value: 4)
!13 = !DIEnumerator(name: "IPPROTO_TCP", value: 6)
!14 = !DIEnumerator(name: "IPPROTO_EGP", value: 8)
!15 = !DIEnumerator(name: "IPPROTO_PUP", value: 12)
!16 = !DIEnumerator(name: "IPPROTO_UDP", value: 17)
!17 = !DIEnumerator(name: "IPPROTO_IDP", value: 22)
!18 = !DIEnumerator(name: "IPPROTO_TP", value: 29)
!19 = !DIEnumerator(name: "IPPROTO_DCCP", value: 33)
!20 = !DIEnumerator(name: "IPPROTO_IPV6", value: 41)
!21 = !DIEnumerator(name: "IPPROTO_RSVP", value: 46)
!22 = !DIEnumerator(name: "IPPROTO_GRE", value: 47)
!23 = !DIEnumerator(name: "IPPROTO_ESP", value: 50)
!24 = !DIEnumerator(name: "IPPROTO_AH", value: 51)
!25 = !DIEnumerator(name: "IPPROTO_MTP", value: 92)
!26 = !DIEnumerator(name: "IPPROTO_BEETPH", value: 94)
!27 = !DIEnumerator(name: "IPPROTO_ENCAP", value: 98)
!28 = !DIEnumerator(name: "IPPROTO_PIM", value: 103)
!29 = !DIEnumerator(name: "IPPROTO_COMP", value: 108)
!30 = !DIEnumerator(name: "IPPROTO_L2TP", value: 115)
!31 = !DIEnumerator(name: "IPPROTO_SCTP", value: 132)
!32 = !DIEnumerator(name: "IPPROTO_UDPLITE", value: 136)
!33 = !DIEnumerator(name: "IPPROTO_MPLS", value: 137)
!34 = !DIEnumerator(name: "IPPROTO_ETHERNET", value: 143)
!35 = !DIEnumerator(name: "IPPROTO_RAW", value: 255)
!36 = !DIEnumerator(name: "IPPROTO_SMC", value: 256)
!37 = !DIEnumerator(name: "IPPROTO_MPTCP", value: 262)
!38 = !DIEnumerator(name: "IPPROTO_MAX", value: 263)
!39 = !{!40, !41, !42}
!40 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!41 = !DIBasicType(name: "long", size: 64, encoding: DW_ATE_signed)
!42 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u16", file: !43, line: 24, baseType: !44)
!43 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "", checksumkind: CSK_MD5, checksum: "b810f270733e106319b67ef512c6246e")
!44 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!45 = !{!0, !46, !299, !307, !313, !319, !325}
!46 = !DIGlobalVariableExpression(var: !47, expr: !DIExpression())
!47 = distinct !DIGlobalVariable(name: "____fmt", scope: !48, file: !3, line: 46, type: !294, isLocal: true, isDefinition: true)
!48 = distinct !DISubprogram(name: "flat", scope: !3, file: !3, line: 45, type: !49, scopeLine: 45, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !156)
!49 = !DISubroutineType(types: !50)
!50 = !{!51, !52}
!51 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!52 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !53, size: 64)
!53 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "__sk_buff", file: !54, line: 6229, size: 1536, elements: !55)
!54 = !DIFile(filename: "/usr/include/linux/bpf.h", directory: "", checksumkind: CSK_MD5, checksum: "eec04c95b9f59f758a8270a58c2ff5f6")
!55 = !{!56, !58, !59, !60, !61, !62, !63, !64, !65, !66, !67, !68, !69, !73, !74, !75, !76, !77, !78, !79, !80, !81, !85, !86, !87, !88, !89, !126, !129, !130, !131, !153, !154, !155}
!56 = !DIDerivedType(tag: DW_TAG_member, name: "len", scope: !53, file: !54, line: 6230, baseType: !57, size: 32)
!57 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !43, line: 27, baseType: !7)
!58 = !DIDerivedType(tag: DW_TAG_member, name: "pkt_type", scope: !53, file: !54, line: 6231, baseType: !57, size: 32, offset: 32)
!59 = !DIDerivedType(tag: DW_TAG_member, name: "mark", scope: !53, file: !54, line: 6232, baseType: !57, size: 32, offset: 64)
!60 = !DIDerivedType(tag: DW_TAG_member, name: "queue_mapping", scope: !53, file: !54, line: 6233, baseType: !57, size: 32, offset: 96)
!61 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !53, file: !54, line: 6234, baseType: !57, size: 32, offset: 128)
!62 = !DIDerivedType(tag: DW_TAG_member, name: "vlan_present", scope: !53, file: !54, line: 6235, baseType: !57, size: 32, offset: 160)
!63 = !DIDerivedType(tag: DW_TAG_member, name: "vlan_tci", scope: !53, file: !54, line: 6236, baseType: !57, size: 32, offset: 192)
!64 = !DIDerivedType(tag: DW_TAG_member, name: "vlan_proto", scope: !53, file: !54, line: 6237, baseType: !57, size: 32, offset: 224)
!65 = !DIDerivedType(tag: DW_TAG_member, name: "priority", scope: !53, file: !54, line: 6238, baseType: !57, size: 32, offset: 256)
!66 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !53, file: !54, line: 6239, baseType: !57, size: 32, offset: 288)
!67 = !DIDerivedType(tag: DW_TAG_member, name: "ifindex", scope: !53, file: !54, line: 6240, baseType: !57, size: 32, offset: 320)
!68 = !DIDerivedType(tag: DW_TAG_member, name: "tc_index", scope: !53, file: !54, line: 6241, baseType: !57, size: 32, offset: 352)
!69 = !DIDerivedType(tag: DW_TAG_member, name: "cb", scope: !53, file: !54, line: 6242, baseType: !70, size: 160, offset: 384)
!70 = !DICompositeType(tag: DW_TAG_array_type, baseType: !57, size: 160, elements: !71)
!71 = !{!72}
!72 = !DISubrange(count: 5)
!73 = !DIDerivedType(tag: DW_TAG_member, name: "hash", scope: !53, file: !54, line: 6243, baseType: !57, size: 32, offset: 544)
!74 = !DIDerivedType(tag: DW_TAG_member, name: "tc_classid", scope: !53, file: !54, line: 6244, baseType: !57, size: 32, offset: 576)
!75 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !53, file: !54, line: 6245, baseType: !57, size: 32, offset: 608)
!76 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !53, file: !54, line: 6246, baseType: !57, size: 32, offset: 640)
!77 = !DIDerivedType(tag: DW_TAG_member, name: "napi_id", scope: !53, file: !54, line: 6247, baseType: !57, size: 32, offset: 672)
!78 = !DIDerivedType(tag: DW_TAG_member, name: "family", scope: !53, file: !54, line: 6250, baseType: !57, size: 32, offset: 704)
!79 = !DIDerivedType(tag: DW_TAG_member, name: "remote_ip4", scope: !53, file: !54, line: 6251, baseType: !57, size: 32, offset: 736)
!80 = !DIDerivedType(tag: DW_TAG_member, name: "local_ip4", scope: !53, file: !54, line: 6252, baseType: !57, size: 32, offset: 768)
!81 = !DIDerivedType(tag: DW_TAG_member, name: "remote_ip6", scope: !53, file: !54, line: 6253, baseType: !82, size: 128, offset: 800)
!82 = !DICompositeType(tag: DW_TAG_array_type, baseType: !57, size: 128, elements: !83)
!83 = !{!84}
!84 = !DISubrange(count: 4)
!85 = !DIDerivedType(tag: DW_TAG_member, name: "local_ip6", scope: !53, file: !54, line: 6254, baseType: !82, size: 128, offset: 928)
!86 = !DIDerivedType(tag: DW_TAG_member, name: "remote_port", scope: !53, file: !54, line: 6255, baseType: !57, size: 32, offset: 1056)
!87 = !DIDerivedType(tag: DW_TAG_member, name: "local_port", scope: !53, file: !54, line: 6256, baseType: !57, size: 32, offset: 1088)
!88 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !53, file: !54, line: 6259, baseType: !57, size: 32, offset: 1120)
!89 = !DIDerivedType(tag: DW_TAG_member, scope: !53, file: !54, line: 6260, baseType: !90, size: 64, align: 64, offset: 1152)
!90 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !53, file: !54, line: 6260, size: 64, align: 64, elements: !91)
!91 = !{!92}
!92 = !DIDerivedType(tag: DW_TAG_member, name: "flow_keys", scope: !90, file: !54, line: 6260, baseType: !93, size: 64)
!93 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !94, size: 64)
!94 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_flow_keys", file: !54, line: 7271, size: 448, elements: !95)
!95 = !{!96, !97, !98, !99, !102, !103, !104, !105, !108, !109, !110, !124, !125}
!96 = !DIDerivedType(tag: DW_TAG_member, name: "nhoff", scope: !94, file: !54, line: 7272, baseType: !42, size: 16)
!97 = !DIDerivedType(tag: DW_TAG_member, name: "thoff", scope: !94, file: !54, line: 7273, baseType: !42, size: 16, offset: 16)
!98 = !DIDerivedType(tag: DW_TAG_member, name: "addr_proto", scope: !94, file: !54, line: 7274, baseType: !42, size: 16, offset: 32)
!99 = !DIDerivedType(tag: DW_TAG_member, name: "is_frag", scope: !94, file: !54, line: 7275, baseType: !100, size: 8, offset: 48)
!100 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u8", file: !43, line: 21, baseType: !101)
!101 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!102 = !DIDerivedType(tag: DW_TAG_member, name: "is_first_frag", scope: !94, file: !54, line: 7276, baseType: !100, size: 8, offset: 56)
!103 = !DIDerivedType(tag: DW_TAG_member, name: "is_encap", scope: !94, file: !54, line: 7277, baseType: !100, size: 8, offset: 64)
!104 = !DIDerivedType(tag: DW_TAG_member, name: "ip_proto", scope: !94, file: !54, line: 7278, baseType: !100, size: 8, offset: 72)
!105 = !DIDerivedType(tag: DW_TAG_member, name: "n_proto", scope: !94, file: !54, line: 7279, baseType: !106, size: 16, offset: 80)
!106 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be16", file: !107, line: 32, baseType: !42)
!107 = !DIFile(filename: "/usr/include/linux/types.h", directory: "", checksumkind: CSK_MD5, checksum: "bf9fbc0e8f60927fef9d8917535375a6")
!108 = !DIDerivedType(tag: DW_TAG_member, name: "sport", scope: !94, file: !54, line: 7280, baseType: !106, size: 16, offset: 96)
!109 = !DIDerivedType(tag: DW_TAG_member, name: "dport", scope: !94, file: !54, line: 7281, baseType: !106, size: 16, offset: 112)
!110 = !DIDerivedType(tag: DW_TAG_member, scope: !94, file: !54, line: 7282, baseType: !111, size: 256, offset: 128)
!111 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !94, file: !54, line: 7282, size: 256, elements: !112)
!112 = !{!113, !119}
!113 = !DIDerivedType(tag: DW_TAG_member, scope: !111, file: !54, line: 7283, baseType: !114, size: 64)
!114 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !111, file: !54, line: 7283, size: 64, elements: !115)
!115 = !{!116, !118}
!116 = !DIDerivedType(tag: DW_TAG_member, name: "ipv4_src", scope: !114, file: !54, line: 7284, baseType: !117, size: 32)
!117 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be32", file: !107, line: 34, baseType: !57)
!118 = !DIDerivedType(tag: DW_TAG_member, name: "ipv4_dst", scope: !114, file: !54, line: 7285, baseType: !117, size: 32, offset: 32)
!119 = !DIDerivedType(tag: DW_TAG_member, scope: !111, file: !54, line: 7287, baseType: !120, size: 256)
!120 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !111, file: !54, line: 7287, size: 256, elements: !121)
!121 = !{!122, !123}
!122 = !DIDerivedType(tag: DW_TAG_member, name: "ipv6_src", scope: !120, file: !54, line: 7288, baseType: !82, size: 128)
!123 = !DIDerivedType(tag: DW_TAG_member, name: "ipv6_dst", scope: !120, file: !54, line: 7289, baseType: !82, size: 128, offset: 128)
!124 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !94, file: !54, line: 7292, baseType: !57, size: 32, offset: 384)
!125 = !DIDerivedType(tag: DW_TAG_member, name: "flow_label", scope: !94, file: !54, line: 7293, baseType: !117, size: 32, offset: 416)
!126 = !DIDerivedType(tag: DW_TAG_member, name: "tstamp", scope: !53, file: !54, line: 6261, baseType: !127, size: 64, offset: 1216)
!127 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !43, line: 31, baseType: !128)
!128 = !DIBasicType(name: "unsigned long long", size: 64, encoding: DW_ATE_unsigned)
!129 = !DIDerivedType(tag: DW_TAG_member, name: "wire_len", scope: !53, file: !54, line: 6262, baseType: !57, size: 32, offset: 1280)
!130 = !DIDerivedType(tag: DW_TAG_member, name: "gso_segs", scope: !53, file: !54, line: 6263, baseType: !57, size: 32, offset: 1312)
!131 = !DIDerivedType(tag: DW_TAG_member, scope: !53, file: !54, line: 6264, baseType: !132, size: 64, align: 64, offset: 1344)
!132 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !53, file: !54, line: 6264, size: 64, align: 64, elements: !133)
!133 = !{!134}
!134 = !DIDerivedType(tag: DW_TAG_member, name: "sk", scope: !132, file: !54, line: 6264, baseType: !135, size: 64)
!135 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !136, size: 64)
!136 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_sock", file: !54, line: 6333, size: 640, elements: !137)
!137 = !{!138, !139, !140, !141, !142, !143, !144, !145, !146, !147, !148, !149, !150, !151}
!138 = !DIDerivedType(tag: DW_TAG_member, name: "bound_dev_if", scope: !136, file: !54, line: 6334, baseType: !57, size: 32)
!139 = !DIDerivedType(tag: DW_TAG_member, name: "family", scope: !136, file: !54, line: 6335, baseType: !57, size: 32, offset: 32)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !136, file: !54, line: 6336, baseType: !57, size: 32, offset: 64)
!141 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !136, file: !54, line: 6337, baseType: !57, size: 32, offset: 96)
!142 = !DIDerivedType(tag: DW_TAG_member, name: "mark", scope: !136, file: !54, line: 6338, baseType: !57, size: 32, offset: 128)
!143 = !DIDerivedType(tag: DW_TAG_member, name: "priority", scope: !136, file: !54, line: 6339, baseType: !57, size: 32, offset: 160)
!144 = !DIDerivedType(tag: DW_TAG_member, name: "src_ip4", scope: !136, file: !54, line: 6341, baseType: !57, size: 32, offset: 192)
!145 = !DIDerivedType(tag: DW_TAG_member, name: "src_ip6", scope: !136, file: !54, line: 6342, baseType: !82, size: 128, offset: 224)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "src_port", scope: !136, file: !54, line: 6343, baseType: !57, size: 32, offset: 352)
!147 = !DIDerivedType(tag: DW_TAG_member, name: "dst_port", scope: !136, file: !54, line: 6344, baseType: !106, size: 16, offset: 384)
!148 = !DIDerivedType(tag: DW_TAG_member, name: "dst_ip4", scope: !136, file: !54, line: 6346, baseType: !57, size: 32, offset: 416)
!149 = !DIDerivedType(tag: DW_TAG_member, name: "dst_ip6", scope: !136, file: !54, line: 6347, baseType: !82, size: 128, offset: 448)
!150 = !DIDerivedType(tag: DW_TAG_member, name: "state", scope: !136, file: !54, line: 6348, baseType: !57, size: 32, offset: 576)
!151 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_mapping", scope: !136, file: !54, line: 6349, baseType: !152, size: 32, offset: 608)
!152 = !DIDerivedType(tag: DW_TAG_typedef, name: "__s32", file: !43, line: 26, baseType: !51)
!153 = !DIDerivedType(tag: DW_TAG_member, name: "gso_size", scope: !53, file: !54, line: 6265, baseType: !57, size: 32, offset: 1408)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "tstamp_type", scope: !53, file: !54, line: 6266, baseType: !100, size: 8, offset: 1440)
!155 = !DIDerivedType(tag: DW_TAG_member, name: "hwtstamp", scope: !53, file: !54, line: 6268, baseType: !127, size: 64, offset: 1472)
!156 = !{!157, !158, !159, !160, !171, !199, !242, !264, !273, !291}
!157 = !DILocalVariable(name: "skb", arg: 1, scope: !48, file: !3, line: 45, type: !52)
!158 = !DILocalVariable(name: "head", scope: !48, file: !3, line: 56, type: !40)
!159 = !DILocalVariable(name: "tail", scope: !48, file: !3, line: 57, type: !40)
!160 = !DILocalVariable(name: "eth", scope: !48, file: !3, line: 65, type: !161)
!161 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !162, size: 64)
!162 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ethhdr", file: !163, line: 173, size: 112, elements: !164)
!163 = !DIFile(filename: "/usr/include/linux/if_ether.h", directory: "", checksumkind: CSK_MD5, checksum: "163f54fb1af2e21fea410f14eb18fa76")
!164 = !{!165, !169, !170}
!165 = !DIDerivedType(tag: DW_TAG_member, name: "h_dest", scope: !162, file: !163, line: 174, baseType: !166, size: 48)
!166 = !DICompositeType(tag: DW_TAG_array_type, baseType: !101, size: 48, elements: !167)
!167 = !{!168}
!168 = !DISubrange(count: 6)
!169 = !DIDerivedType(tag: DW_TAG_member, name: "h_source", scope: !162, file: !163, line: 175, baseType: !166, size: 48, offset: 48)
!170 = !DIDerivedType(tag: DW_TAG_member, name: "h_proto", scope: !162, file: !163, line: 176, baseType: !106, size: 16, offset: 96)
!171 = !DILocalVariable(name: "ip", scope: !48, file: !3, line: 66, type: !172)
!172 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !173, size: 64)
!173 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "iphdr", file: !174, line: 87, size: 160, elements: !175)
!174 = !DIFile(filename: "/usr/include/linux/ip.h", directory: "", checksumkind: CSK_MD5, checksum: "149778ace30a1ff208adc8783fd04b29")
!175 = !{!176, !177, !178, !179, !180, !181, !182, !183, !184, !186}
!176 = !DIDerivedType(tag: DW_TAG_member, name: "ihl", scope: !173, file: !174, line: 89, baseType: !100, size: 4, flags: DIFlagBitField, extraData: i64 0)
!177 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !173, file: !174, line: 90, baseType: !100, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!178 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !173, file: !174, line: 97, baseType: !100, size: 8, offset: 8)
!179 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !173, file: !174, line: 98, baseType: !106, size: 16, offset: 16)
!180 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !173, file: !174, line: 99, baseType: !106, size: 16, offset: 32)
!181 = !DIDerivedType(tag: DW_TAG_member, name: "frag_off", scope: !173, file: !174, line: 100, baseType: !106, size: 16, offset: 48)
!182 = !DIDerivedType(tag: DW_TAG_member, name: "ttl", scope: !173, file: !174, line: 101, baseType: !100, size: 8, offset: 64)
!183 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !173, file: !174, line: 102, baseType: !100, size: 8, offset: 72)
!184 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !173, file: !174, line: 103, baseType: !185, size: 16, offset: 80)
!185 = !DIDerivedType(tag: DW_TAG_typedef, name: "__sum16", file: !107, line: 38, baseType: !42)
!186 = !DIDerivedType(tag: DW_TAG_member, scope: !173, file: !174, line: 104, baseType: !187, size: 64, offset: 96)
!187 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !173, file: !174, line: 104, size: 64, elements: !188)
!188 = !{!189, !194}
!189 = !DIDerivedType(tag: DW_TAG_member, scope: !187, file: !174, line: 104, baseType: !190, size: 64)
!190 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !187, file: !174, line: 104, size: 64, elements: !191)
!191 = !{!192, !193}
!192 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !190, file: !174, line: 104, baseType: !117, size: 32)
!193 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !190, file: !174, line: 104, baseType: !117, size: 32, offset: 32)
!194 = !DIDerivedType(tag: DW_TAG_member, name: "addrs", scope: !187, file: !174, line: 104, baseType: !195, size: 64)
!195 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !187, file: !174, line: 104, size: 64, elements: !196)
!196 = !{!197, !198}
!197 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !195, file: !174, line: 104, baseType: !117, size: 32)
!198 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !195, file: !174, line: 104, baseType: !117, size: 32, offset: 32)
!199 = !DILocalVariable(name: "ipv6", scope: !48, file: !3, line: 67, type: !200)
!200 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !201, size: 64)
!201 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ipv6hdr", file: !202, line: 118, size: 320, elements: !203)
!202 = !DIFile(filename: "/usr/include/linux/ipv6.h", directory: "", checksumkind: CSK_MD5, checksum: "d288e308e142e51c48e7422f4fbbaa3f")
!203 = !{!204, !205, !206, !210, !211, !212, !213}
!204 = !DIDerivedType(tag: DW_TAG_member, name: "priority", scope: !201, file: !202, line: 120, baseType: !100, size: 4, flags: DIFlagBitField, extraData: i64 0)
!205 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !201, file: !202, line: 121, baseType: !100, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!206 = !DIDerivedType(tag: DW_TAG_member, name: "flow_lbl", scope: !201, file: !202, line: 128, baseType: !207, size: 24, offset: 8)
!207 = !DICompositeType(tag: DW_TAG_array_type, baseType: !100, size: 24, elements: !208)
!208 = !{!209}
!209 = !DISubrange(count: 3)
!210 = !DIDerivedType(tag: DW_TAG_member, name: "payload_len", scope: !201, file: !202, line: 130, baseType: !106, size: 16, offset: 32)
!211 = !DIDerivedType(tag: DW_TAG_member, name: "nexthdr", scope: !201, file: !202, line: 131, baseType: !100, size: 8, offset: 48)
!212 = !DIDerivedType(tag: DW_TAG_member, name: "hop_limit", scope: !201, file: !202, line: 132, baseType: !100, size: 8, offset: 56)
!213 = !DIDerivedType(tag: DW_TAG_member, scope: !201, file: !202, line: 134, baseType: !214, size: 256, offset: 64)
!214 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !201, file: !202, line: 134, size: 256, elements: !215)
!215 = !{!216, !237}
!216 = !DIDerivedType(tag: DW_TAG_member, scope: !214, file: !202, line: 134, baseType: !217, size: 256)
!217 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !214, file: !202, line: 134, size: 256, elements: !218)
!218 = !{!219, !236}
!219 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !217, file: !202, line: 134, baseType: !220, size: 128)
!220 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in6_addr", file: !221, line: 33, size: 128, elements: !222)
!221 = !DIFile(filename: "/usr/include/linux/in6.h", directory: "", checksumkind: CSK_MD5, checksum: "fca1889f0274df066e49cf4d8db8011e")
!222 = !{!223}
!223 = !DIDerivedType(tag: DW_TAG_member, name: "in6_u", scope: !220, file: !221, line: 40, baseType: !224, size: 128)
!224 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !220, file: !221, line: 34, size: 128, elements: !225)
!225 = !{!226, !230, !234}
!226 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr8", scope: !224, file: !221, line: 35, baseType: !227, size: 128)
!227 = !DICompositeType(tag: DW_TAG_array_type, baseType: !100, size: 128, elements: !228)
!228 = !{!229}
!229 = !DISubrange(count: 16)
!230 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr16", scope: !224, file: !221, line: 37, baseType: !231, size: 128)
!231 = !DICompositeType(tag: DW_TAG_array_type, baseType: !106, size: 128, elements: !232)
!232 = !{!233}
!233 = !DISubrange(count: 8)
!234 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr32", scope: !224, file: !221, line: 38, baseType: !235, size: 128)
!235 = !DICompositeType(tag: DW_TAG_array_type, baseType: !117, size: 128, elements: !83)
!236 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !217, file: !202, line: 134, baseType: !220, size: 128, offset: 128)
!237 = !DIDerivedType(tag: DW_TAG_member, name: "addrs", scope: !214, file: !202, line: 134, baseType: !238, size: 256)
!238 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !214, file: !202, line: 134, size: 256, elements: !239)
!239 = !{!240, !241}
!240 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !238, file: !202, line: 134, baseType: !220, size: 128)
!241 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !238, file: !202, line: 134, baseType: !220, size: 128, offset: 128)
!242 = !DILocalVariable(name: "tcp", scope: !48, file: !3, line: 68, type: !243)
!243 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !244, size: 64)
!244 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "tcphdr", file: !245, line: 25, size: 160, elements: !246)
!245 = !DIFile(filename: "/usr/include/linux/tcp.h", directory: "", checksumkind: CSK_MD5, checksum: "1aa35012f509549bad9f3decb5d3e7a2")
!246 = !{!247, !248, !249, !250, !251, !252, !253, !254, !255, !256, !257, !258, !259, !260, !261, !262, !263}
!247 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !244, file: !245, line: 26, baseType: !106, size: 16)
!248 = !DIDerivedType(tag: DW_TAG_member, name: "dest", scope: !244, file: !245, line: 27, baseType: !106, size: 16, offset: 16)
!249 = !DIDerivedType(tag: DW_TAG_member, name: "seq", scope: !244, file: !245, line: 28, baseType: !117, size: 32, offset: 32)
!250 = !DIDerivedType(tag: DW_TAG_member, name: "ack_seq", scope: !244, file: !245, line: 29, baseType: !117, size: 32, offset: 64)
!251 = !DIDerivedType(tag: DW_TAG_member, name: "res1", scope: !244, file: !245, line: 31, baseType: !42, size: 4, offset: 96, flags: DIFlagBitField, extraData: i64 96)
!252 = !DIDerivedType(tag: DW_TAG_member, name: "doff", scope: !244, file: !245, line: 32, baseType: !42, size: 4, offset: 100, flags: DIFlagBitField, extraData: i64 96)
!253 = !DIDerivedType(tag: DW_TAG_member, name: "fin", scope: !244, file: !245, line: 33, baseType: !42, size: 1, offset: 104, flags: DIFlagBitField, extraData: i64 96)
!254 = !DIDerivedType(tag: DW_TAG_member, name: "syn", scope: !244, file: !245, line: 34, baseType: !42, size: 1, offset: 105, flags: DIFlagBitField, extraData: i64 96)
!255 = !DIDerivedType(tag: DW_TAG_member, name: "rst", scope: !244, file: !245, line: 35, baseType: !42, size: 1, offset: 106, flags: DIFlagBitField, extraData: i64 96)
!256 = !DIDerivedType(tag: DW_TAG_member, name: "psh", scope: !244, file: !245, line: 36, baseType: !42, size: 1, offset: 107, flags: DIFlagBitField, extraData: i64 96)
!257 = !DIDerivedType(tag: DW_TAG_member, name: "ack", scope: !244, file: !245, line: 37, baseType: !42, size: 1, offset: 108, flags: DIFlagBitField, extraData: i64 96)
!258 = !DIDerivedType(tag: DW_TAG_member, name: "urg", scope: !244, file: !245, line: 38, baseType: !42, size: 1, offset: 109, flags: DIFlagBitField, extraData: i64 96)
!259 = !DIDerivedType(tag: DW_TAG_member, name: "ece", scope: !244, file: !245, line: 39, baseType: !42, size: 1, offset: 110, flags: DIFlagBitField, extraData: i64 96)
!260 = !DIDerivedType(tag: DW_TAG_member, name: "cwr", scope: !244, file: !245, line: 40, baseType: !42, size: 1, offset: 111, flags: DIFlagBitField, extraData: i64 96)
!261 = !DIDerivedType(tag: DW_TAG_member, name: "window", scope: !244, file: !245, line: 55, baseType: !106, size: 16, offset: 112)
!262 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !244, file: !245, line: 56, baseType: !185, size: 16, offset: 128)
!263 = !DIDerivedType(tag: DW_TAG_member, name: "urg_ptr", scope: !244, file: !245, line: 57, baseType: !106, size: 16, offset: 144)
!264 = !DILocalVariable(name: "udp", scope: !48, file: !3, line: 69, type: !265)
!265 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !266, size: 64)
!266 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "udphdr", file: !267, line: 23, size: 64, elements: !268)
!267 = !DIFile(filename: "/usr/include/linux/udp.h", directory: "", checksumkind: CSK_MD5, checksum: "40b541977cf3a9ce2b2728b52f4091a4")
!268 = !{!269, !270, !271, !272}
!269 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !266, file: !267, line: 24, baseType: !106, size: 16)
!270 = !DIDerivedType(tag: DW_TAG_member, name: "dest", scope: !266, file: !267, line: 25, baseType: !106, size: 16, offset: 16)
!271 = !DIDerivedType(tag: DW_TAG_member, name: "len", scope: !266, file: !267, line: 26, baseType: !106, size: 16, offset: 32)
!272 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !266, file: !267, line: 27, baseType: !185, size: 16, offset: 48)
!273 = !DILocalVariable(name: "pkt", scope: !48, file: !3, line: 71, type: !274)
!274 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "packet_t", file: !3, line: 27, size: 384, elements: !275)
!275 = !{!276, !277, !278, !279, !280, !281, !282, !284, !285}
!276 = !DIDerivedType(tag: DW_TAG_member, name: "src_ip", scope: !274, file: !3, line: 28, baseType: !220, size: 128)
!277 = !DIDerivedType(tag: DW_TAG_member, name: "dst_ip", scope: !274, file: !3, line: 29, baseType: !220, size: 128, offset: 128)
!278 = !DIDerivedType(tag: DW_TAG_member, name: "src_port", scope: !274, file: !3, line: 30, baseType: !106, size: 16, offset: 256)
!279 = !DIDerivedType(tag: DW_TAG_member, name: "dst_port", scope: !274, file: !3, line: 31, baseType: !106, size: 16, offset: 272)
!280 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !274, file: !3, line: 32, baseType: !100, size: 8, offset: 288)
!281 = !DIDerivedType(tag: DW_TAG_member, name: "ttl", scope: !274, file: !3, line: 33, baseType: !100, size: 8, offset: 296)
!282 = !DIDerivedType(tag: DW_TAG_member, name: "syn", scope: !274, file: !3, line: 34, baseType: !283, size: 8, offset: 304)
!283 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!284 = !DIDerivedType(tag: DW_TAG_member, name: "ack", scope: !274, file: !3, line: 35, baseType: !283, size: 8, offset: 312)
!285 = !DIDerivedType(tag: DW_TAG_member, name: "ts", scope: !274, file: !3, line: 36, baseType: !286, size: 64, offset: 320)
!286 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !287, line: 27, baseType: !288)
!287 = !DIFile(filename: "/usr/include/bits/stdint-uintn.h", directory: "", checksumkind: CSK_MD5, checksum: "256fcabbefa27ca8cf5e6d37525e6e16")
!288 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint64_t", file: !289, line: 45, baseType: !290)
!289 = !DIFile(filename: "/usr/include/bits/types.h", directory: "", checksumkind: CSK_MD5, checksum: "e1865d9fe29fe1b5ced550b7ba458f9e")
!290 = !DIBasicType(name: "unsigned long", size: 64, encoding: DW_ATE_unsigned)
!291 = !DILocalVariable(name: "offset", scope: !48, file: !3, line: 72, type: !292)
!292 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !287, line: 26, baseType: !293)
!293 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !289, line: 42, baseType: !7)
!294 = !DICompositeType(tag: DW_TAG_array_type, baseType: !295, size: 120, elements: !297)
!295 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !296)
!296 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!297 = !{!298}
!298 = !DISubrange(count: 15)
!299 = !DIGlobalVariableExpression(var: !300, expr: !DIExpression())
!300 = distinct !DIGlobalVariable(name: "bpf_trace_printk", scope: !2, file: !301, line: 177, type: !302, isLocal: true, isDefinition: true)
!301 = !DIFile(filename: "/usr/include/bpf/bpf_helper_defs.h", directory: "", checksumkind: CSK_MD5, checksum: "65e4dc8e3121f91a5c2c9eb8563c5692")
!302 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !303)
!303 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !304, size: 64)
!304 = !DISubroutineType(types: !305)
!305 = !{!41, !306, !57, null}
!306 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !295, size: 64)
!307 = !DIGlobalVariableExpression(var: !308, expr: !DIExpression())
!308 = distinct !DIGlobalVariable(name: "bpf_skb_pull_data", scope: !2, file: !301, line: 1047, type: !309, isLocal: true, isDefinition: true)
!309 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !310)
!310 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !311, size: 64)
!311 = !DISubroutineType(types: !312)
!312 = !{!41, !52, !57}
!313 = !DIGlobalVariableExpression(var: !314, expr: !DIExpression())
!314 = distinct !DIGlobalVariable(name: "bpf_ktime_get_ns", scope: !2, file: !301, line: 114, type: !315, isLocal: true, isDefinition: true)
!315 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !316)
!316 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !317, size: 64)
!317 = !DISubroutineType(types: !318)
!318 = !{!127}
!319 = !DIGlobalVariableExpression(var: !320, expr: !DIExpression())
!320 = distinct !DIGlobalVariable(name: "bpf_ringbuf_output", scope: !2, file: !301, line: 3164, type: !321, isLocal: true, isDefinition: true)
!321 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !322)
!322 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !323, size: 64)
!323 = !DISubroutineType(types: !324)
!324 = !{!41, !40, !40, !127, !127}
!325 = !DIGlobalVariableExpression(var: !326, expr: !DIExpression())
!326 = distinct !DIGlobalVariable(name: "pipe", scope: !2, file: !3, line: 42, type: !327, isLocal: false, isDefinition: true)
!327 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !3, line: 39, size: 128, elements: !328)
!328 = !{!329, !334}
!329 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !327, file: !3, line: 40, baseType: !330, size: 64)
!330 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !331, size: 64)
!331 = !DICompositeType(tag: DW_TAG_array_type, baseType: !51, size: 864, elements: !332)
!332 = !{!333}
!333 = !DISubrange(count: 27)
!334 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !327, file: !3, line: 41, baseType: !335, size: 64, offset: 64)
!335 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !336, size: 64)
!336 = !DICompositeType(tag: DW_TAG_array_type, baseType: !51, size: 16777216, elements: !337)
!337 = !{!338}
!338 = !DISubrange(count: 524288)
!339 = !DICompositeType(tag: DW_TAG_array_type, baseType: !296, size: 104, elements: !340)
!340 = !{!341}
!341 = !DISubrange(count: 13)
!342 = !{i32 7, !"Dwarf Version", i32 5}
!343 = !{i32 2, !"Debug Info Version", i32 3}
!344 = !{i32 1, !"wchar_size", i32 4}
!345 = !{i32 7, !"frame-pointer", i32 2}
!346 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
!347 = !{!"Ubuntu clang version 19.1.1 (1ubuntu1)"}
!348 = distinct !DIAssignID()
!349 = !DILocation(line: 0, scope: !48)
!350 = !DILocation(line: 46, column: 5, scope: !351)
!351 = distinct !DILexicalBlock(scope: !48, file: !3, line: 46, column: 5)
!352 = !DILocation(line: 48, column: 9, scope: !353)
!353 = distinct !DILexicalBlock(scope: !48, file: !3, line: 48, column: 9)
!354 = !DILocation(line: 48, column: 35, scope: !353)
!355 = !DILocation(line: 48, column: 9, scope: !48)
!356 = !DILocation(line: 52, column: 14, scope: !357)
!357 = distinct !DILexicalBlock(scope: !48, file: !3, line: 52, column: 9)
!358 = !{!359, !360, i64 4}
!359 = !{!"__sk_buff", !360, i64 0, !360, i64 4, !360, i64 8, !360, i64 12, !360, i64 16, !360, i64 20, !360, i64 24, !360, i64 28, !360, i64 32, !360, i64 36, !360, i64 40, !360, i64 44, !361, i64 48, !360, i64 68, !360, i64 72, !360, i64 76, !360, i64 80, !360, i64 84, !360, i64 88, !360, i64 92, !360, i64 96, !361, i64 100, !361, i64 116, !360, i64 132, !360, i64 136, !360, i64 140, !361, i64 144, !363, i64 152, !360, i64 160, !360, i64 164, !361, i64 168, !360, i64 176, !361, i64 180, !363, i64 184}
!360 = !{!"int", !361, i64 0}
!361 = !{!"omnipotent char", !362, i64 0}
!362 = !{!"Simple C/C++ TBAA"}
!363 = !{!"long long", !361, i64 0}
!364 = !DILocation(line: 52, column: 43, scope: !357)
!365 = !DILocation(line: 56, column: 36, scope: !48)
!366 = !{!359, !360, i64 76}
!367 = !DILocation(line: 56, column: 25, scope: !48)
!368 = !DILocation(line: 56, column: 18, scope: !48)
!369 = !DILocation(line: 57, column: 36, scope: !48)
!370 = !{!359, !360, i64 80}
!371 = !DILocation(line: 57, column: 25, scope: !48)
!372 = !DILocation(line: 57, column: 18, scope: !48)
!373 = !DILocation(line: 61, column: 14, scope: !374)
!374 = distinct !DILexicalBlock(scope: !48, file: !3, line: 61, column: 9)
!375 = !DILocation(line: 61, column: 38, scope: !374)
!376 = !DILocation(line: 61, column: 9, scope: !48)
!377 = !DILocation(line: 71, column: 5, scope: !48)
!378 = !DILocation(line: 71, column: 21, scope: !48)
!379 = distinct !DIAssignID()
!380 = !DILocation(line: 77, column: 13, scope: !48)
!381 = !{!382, !383, i64 12}
!382 = !{!"ethhdr", !361, i64 0, !361, i64 6, !383, i64 12}
!383 = !{!"short", !361, i64 0}
!384 = !DILocation(line: 77, column: 5, scope: !48)
!385 = !DILocation(line: 81, column: 18, scope: !386)
!386 = distinct !DILexicalBlock(scope: !387, file: !3, line: 81, column: 13)
!387 = distinct !DILexicalBlock(scope: !48, file: !3, line: 77, column: 38)
!388 = !DILocation(line: 81, column: 27, scope: !386)
!389 = !DILocation(line: 81, column: 13, scope: !387)
!390 = !DILocation(line: 87, column: 17, scope: !391)
!391 = distinct !DILexicalBlock(scope: !387, file: !3, line: 87, column: 13)
!392 = !{!393, !361, i64 9}
!393 = !{!"iphdr", !361, i64 0, !361, i64 0, !361, i64 1, !383, i64 2, !383, i64 4, !383, i64 6, !361, i64 8, !361, i64 9, !383, i64 10, !361, i64 12}
!394 = !DILocation(line: 87, column: 41, scope: !391)
!395 = !DILocation(line: 92, column: 45, scope: !387)
!396 = !{!361, !361, i64 0}
!397 = !DILocation(line: 92, column: 9, scope: !387)
!398 = !DILocation(line: 92, column: 39, scope: !387)
!399 = distinct !DIAssignID()
!400 = !DILocation(line: 93, column: 45, scope: !387)
!401 = !DILocation(line: 93, column: 9, scope: !387)
!402 = !DILocation(line: 93, column: 39, scope: !387)
!403 = distinct !DIAssignID()
!404 = !DILocation(line: 96, column: 9, scope: !387)
!405 = !DILocation(line: 96, column: 39, scope: !387)
!406 = distinct !DIAssignID()
!407 = !DILocation(line: 97, column: 9, scope: !387)
!408 = !DILocation(line: 97, column: 39, scope: !387)
!409 = distinct !DIAssignID()
!410 = !DILocation(line: 99, column: 22, scope: !387)
!411 = !{!412, !361, i64 36}
!412 = !{!"packet_t", !413, i64 0, !413, i64 16, !383, i64 32, !383, i64 34, !361, i64 36, !361, i64 37, !414, i64 38, !414, i64 39, !415, i64 40}
!413 = !{!"in6_addr", !361, i64 0}
!414 = !{!"_Bool", !361, i64 0}
!415 = !{!"long", !361, i64 0}
!416 = distinct !DIAssignID()
!417 = !DILocation(line: 100, column: 23, scope: !387)
!418 = !{!393, !361, i64 8}
!419 = !DILocation(line: 100, column: 13, scope: !387)
!420 = !DILocation(line: 100, column: 17, scope: !387)
!421 = !{!412, !361, i64 37}
!422 = distinct !DIAssignID()
!423 = !DILocation(line: 130, column: 23, scope: !424)
!424 = distinct !DILexicalBlock(scope: !48, file: !3, line: 130, column: 9)
!425 = !DILocation(line: 130, column: 47, scope: !424)
!426 = !DILocation(line: 130, column: 54, scope: !424)
!427 = !DILocation(line: 135, column: 5, scope: !48)
!428 = !DILocation(line: 139, column: 18, scope: !429)
!429 = distinct !DILexicalBlock(scope: !430, file: !3, line: 139, column: 13)
!430 = distinct !DILexicalBlock(scope: !48, file: !3, line: 135, column: 27)
!431 = !DILocation(line: 139, column: 13, scope: !429)
!432 = !DILocation(line: 139, column: 13, scope: !430)
!433 = !DILocation(line: 140, column: 33, scope: !434)
!434 = distinct !DILexicalBlock(scope: !429, file: !3, line: 139, column: 23)
!435 = !{!436, !383, i64 0}
!436 = !{!"tcphdr", !383, i64 0, !383, i64 2, !360, i64 4, !360, i64 8, !383, i64 12, !383, i64 12, !383, i64 13, !383, i64 13, !383, i64 13, !383, i64 13, !383, i64 13, !383, i64 13, !383, i64 13, !383, i64 13, !383, i64 14, !383, i64 16, !383, i64 18}
!437 = !DILocation(line: 140, column: 17, scope: !434)
!438 = !DILocation(line: 140, column: 26, scope: !434)
!439 = !{!412, !383, i64 32}
!440 = distinct !DIAssignID()
!441 = !DILocation(line: 141, column: 33, scope: !434)
!442 = !{!436, !383, i64 2}
!443 = !DILocation(line: 141, column: 17, scope: !434)
!444 = !DILocation(line: 141, column: 26, scope: !434)
!445 = !{!412, !383, i64 34}
!446 = distinct !DIAssignID()
!447 = !DILocation(line: 142, column: 17, scope: !434)
!448 = !DILocation(line: 142, column: 21, scope: !434)
!449 = !{!412, !414, i64 38}
!450 = distinct !DIAssignID()
!451 = !DILocation(line: 143, column: 17, scope: !434)
!452 = !DILocation(line: 143, column: 21, scope: !434)
!453 = !{!412, !414, i64 39}
!454 = distinct !DIAssignID()
!455 = distinct !DIAssignID()
!456 = !DILocation(line: 147, column: 17, scope: !434)
!457 = !DILocation(line: 157, column: 29, scope: !430)
!458 = !{!459, !383, i64 0}
!459 = !{!"udphdr", !383, i64 0, !383, i64 2, !383, i64 4, !383, i64 6}
!460 = !DILocation(line: 157, column: 13, scope: !430)
!461 = !DILocation(line: 157, column: 22, scope: !430)
!462 = distinct !DIAssignID()
!463 = !DILocation(line: 158, column: 29, scope: !430)
!464 = !{!459, !383, i64 2}
!465 = !DILocation(line: 158, column: 13, scope: !430)
!466 = !DILocation(line: 158, column: 22, scope: !430)
!467 = distinct !DIAssignID()
!468 = !DILocation(line: 162, column: 13, scope: !430)
!469 = !DILocation(line: 0, scope: !430)
!470 = !{!412, !415, i64 40}
!471 = !DILocation(line: 172, column: 1, scope: !48)
