; ModuleID = 'kill.c'
source_filename = "kill.c"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf"

%struct.syscalls_enter_kill_args = type { i64, i64, i64, i64 }

@LICENSE = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !0
@__const.kill_example.fmt = private unnamed_addr constant [25 x i8] c"PID %u is being killed!\0A\00", align 1
@llvm.compiler.used = appending global [2 x ptr] [ptr @LICENSE, ptr @kill_example], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local noundef i32 @kill_example(ptr nocapture noundef readonly %0) #0 section "tracepoint/syscalls/sys_enter_kill" !dbg !27 {
  %2 = alloca [25 x i8], align 1, !DIAssignID !45
  call void @llvm.dbg.assign(metadata i1 undef, metadata !41, metadata !DIExpression(), metadata !45, metadata ptr %2, metadata !DIExpression()), !dbg !46
  tail call void @llvm.dbg.value(metadata ptr %0, metadata !40, metadata !DIExpression()), !dbg !46
  %3 = getelementptr inbounds %struct.syscalls_enter_kill_args, ptr %0, i64 0, i32 3, !dbg !47
  %4 = load i64, ptr %3, align 8, !dbg !47, !tbaa !49
  %5 = icmp eq i64 %4, 9, !dbg !55
  br i1 %5, label %6, label %10, !dbg !56

6:                                                ; preds = %1
  call void @llvm.lifetime.start.p0(i64 25, ptr nonnull %2) #5, !dbg !57
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(25) %2, ptr noundef nonnull align 1 dereferenceable(25) @__const.kill_example.fmt, i64 25, i1 false), !dbg !58, !DIAssignID !59
  call void @llvm.dbg.assign(metadata i1 undef, metadata !41, metadata !DIExpression(), metadata !59, metadata ptr %2, metadata !DIExpression()), !dbg !46
  %7 = getelementptr inbounds %struct.syscalls_enter_kill_args, ptr %0, i64 0, i32 2, !dbg !60
  %8 = load i64, ptr %7, align 8, !dbg !60, !tbaa !61
  %9 = call i64 (ptr, i32, ...) inttoptr (i64 6 to ptr)(ptr noundef nonnull %2, i32 noundef 25, i64 noundef %8, i64 noundef 8) #5, !dbg !62
  call void @llvm.lifetime.end.p0(i64 25, ptr nonnull %2) #5, !dbg !63
  br label %10

10:                                               ; preds = %1, %6
  ret i32 0, !dbg !63
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.assign(metadata, metadata, metadata, metadata, metadata, metadata) #3

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.value(metadata, metadata, metadata) #4

attributes #0 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #4 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #5 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!21, !22, !23, !24, !25}
!llvm.ident = !{!26}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "LICENSE", scope: !2, file: !3, line: 4, type: !18, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C11, file: !3, producer: "Ubuntu clang version 18.1.3 (1ubuntu1)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, globals: !4, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "kill.c", directory: "/Users/cassamajor/code/cnf/tutorial", checksumkind: CSK_MD5, checksum: "5c4018e18c44870afe71c494380a4f2c")
!4 = !{!0, !5}
!5 = !DIGlobalVariableExpression(var: !6, expr: !DIExpression(DW_OP_constu, 6, DW_OP_stack_value))
!6 = distinct !DIGlobalVariable(name: "bpf_trace_printk", scope: !2, file: !7, line: 177, type: !8, isLocal: true, isDefinition: true)
!7 = !DIFile(filename: "/usr/include/bpf/bpf_helper_defs.h", directory: "", checksumkind: CSK_MD5, checksum: "09cfcd7169c24bec448f30582e8c6db9")
!8 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !9, size: 64)
!9 = !DISubroutineType(types: !10)
!10 = !{!11, !12, !15, null}
!11 = !DIBasicType(name: "long", size: 64, encoding: DW_ATE_signed)
!12 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !13, size: 64)
!13 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !14)
!14 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!15 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !16, line: 27, baseType: !17)
!16 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "", checksumkind: CSK_MD5, checksum: "b810f270733e106319b67ef512c6246e")
!17 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!18 = !DICompositeType(tag: DW_TAG_array_type, baseType: !14, size: 32, elements: !19)
!19 = !{!20}
!20 = !DISubrange(count: 4)
!21 = !{i32 7, !"Dwarf Version", i32 5}
!22 = !{i32 2, !"Debug Info Version", i32 3}
!23 = !{i32 1, !"wchar_size", i32 4}
!24 = !{i32 7, !"frame-pointer", i32 2}
!25 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
!26 = !{!"Ubuntu clang version 18.1.3 (1ubuntu1)"}
!27 = distinct !DISubprogram(name: "kill_example", scope: !3, file: !3, line: 15, type: !28, scopeLine: 15, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !39)
!28 = !DISubroutineType(types: !29)
!29 = !{!30, !31}
!30 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!31 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !32, size: 64)
!32 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "syscalls_enter_kill_args", file: !3, line: 6, size: 256, elements: !33)
!33 = !{!34, !36, !37, !38}
!34 = !DIDerivedType(tag: DW_TAG_member, name: "pad", scope: !32, file: !3, line: 7, baseType: !35, size: 64)
!35 = !DIBasicType(name: "long long", size: 64, encoding: DW_ATE_signed)
!36 = !DIDerivedType(tag: DW_TAG_member, name: "syscall_nr", scope: !32, file: !3, line: 9, baseType: !11, size: 64, offset: 64)
!37 = !DIDerivedType(tag: DW_TAG_member, name: "pid", scope: !32, file: !3, line: 10, baseType: !11, size: 64, offset: 128)
!38 = !DIDerivedType(tag: DW_TAG_member, name: "sig", scope: !32, file: !3, line: 11, baseType: !11, size: 64, offset: 192)
!39 = !{!40, !41}
!40 = !DILocalVariable(name: "ctx", arg: 1, scope: !27, file: !3, line: 15, type: !31)
!41 = !DILocalVariable(name: "fmt", scope: !27, file: !3, line: 18, type: !42)
!42 = !DICompositeType(tag: DW_TAG_array_type, baseType: !14, size: 200, elements: !43)
!43 = !{!44}
!44 = !DISubrange(count: 25)
!45 = distinct !DIAssignID()
!46 = !DILocation(line: 0, scope: !27)
!47 = !DILocation(line: 16, column: 13, scope: !48)
!48 = distinct !DILexicalBlock(scope: !27, file: !3, line: 16, column: 8)
!49 = !{!50, !54, i64 24}
!50 = !{!"syscalls_enter_kill_args", !51, i64 0, !54, i64 8, !54, i64 16, !54, i64 24}
!51 = !{!"long long", !52, i64 0}
!52 = !{!"omnipotent char", !53, i64 0}
!53 = !{!"Simple C/C++ TBAA"}
!54 = !{!"long", !52, i64 0}
!55 = !DILocation(line: 16, column: 17, scope: !48)
!56 = !DILocation(line: 16, column: 8, scope: !27)
!57 = !DILocation(line: 18, column: 5, scope: !27)
!58 = !DILocation(line: 18, column: 10, scope: !27)
!59 = distinct !DIAssignID()
!60 = !DILocation(line: 19, column: 45, scope: !27)
!61 = !{!50, !54, i64 16}
!62 = !DILocation(line: 19, column: 5, scope: !27)
!63 = !DILocation(line: 22, column: 1, scope: !27)
