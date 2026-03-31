// wyvern-cube-model.js - Кубическая виверна (Minecraft стиль)
import * as THREE from 'three';

export function createWyvern() {
    const group = new THREE.Group();
    
    // Цвета
    const bodyColor = 0x4a2a1a;        // Коричневый
    const wingColor = 0x6a3a2a;        // Тёмно-коричневый
    const bellyColor = 0xbd7a4a;        // Светло-коричневый
    const eyeColor = 0xffaa44;          // Жёлтый
    const hornColor = 0x8b5a2b;         // Роговой
    const clawColor = 0xaa8866;         // Когти
    const spikeColor = 0x8b5a2b;        // Шипы
    
    // Материалы
    const bodyMat = new THREE.MeshStandardMaterial({ color: bodyColor, roughness: 0.5 });
    const wingMat = new THREE.MeshStandardMaterial({ color: wingColor, roughness: 0.6 });
    const bellyMat = new THREE.MeshStandardMaterial({ color: bellyColor, roughness: 0.6 });
    const eyeMat = new THREE.MeshStandardMaterial({ color: eyeColor, emissive: 0x442200, emissiveIntensity: 0.2 });
    const hornMat = new THREE.MeshStandardMaterial({ color: hornColor, roughness: 0.4 });
    const clawMat = new THREE.MeshStandardMaterial({ color: clawColor, roughness: 0.3 });
    const spikeMat = new THREE.MeshStandardMaterial({ color: spikeColor, roughness: 0.4 });
    
    // ==================== ТЕЛО ====================
    // Основное тело
    const body = new THREE.Mesh(new THREE.BoxGeometry(1.0, 0.8, 1.4), bodyMat);
    body.position.set(0, 0.2, 0);
    body.castShadow = true;
    body.receiveShadow = true;
    group.add(body);
    
    // Грудная клетка (верхняя часть)
    const chest = new THREE.Mesh(new THREE.BoxGeometry(0.9, 0.7, 0.9), bodyMat);
    chest.position.set(0, 0.5, 0.55);
    chest.castShadow = true;
    group.add(chest);
    
    // Живот (светлый)
    const belly = new THREE.Mesh(new THREE.BoxGeometry(0.85, 0.5, 1.2), bellyMat);
    belly.position.set(0, -0.05, 0.25);
    belly.castShadow = true;
    group.add(belly);
    
    // Спина (тёмная полоса)
    const back = new THREE.Mesh(new THREE.BoxGeometry(0.8, 0.35, 1.1), new THREE.MeshStandardMaterial({ color: 0x3a1a0a }));
    back.position.set(0, 0.6, -0.15);
    back.castShadow = true;
    group.add(back);
    
    // ==================== ШЕЯ ====================
    // Нижняя часть шеи
    const neckLower = new THREE.Mesh(new THREE.BoxGeometry(0.6, 0.55, 0.65), bodyMat);
    neckLower.position.set(0, 0.75, 0.6);
    neckLower.castShadow = true;
    group.add(neckLower);
    
    // Средняя часть шеи
    const neckMid = new THREE.Mesh(new THREE.BoxGeometry(0.5, 0.5, 0.6), bodyMat);
    neckMid.position.set(0, 1.05, 0.85);
    neckMid.castShadow = true;
    group.add(neckMid);
    
    // Верхняя часть шеи
    const neckUpper = new THREE.Mesh(new THREE.BoxGeometry(0.45, 0.48, 0.58), bodyMat);
    neckUpper.position.set(0, 1.32, 1.08);
    neckUpper.castShadow = true;
    group.add(neckUpper);
    
    // ==================== ГОЛОВА ====================
    // Основа головы
    const head = new THREE.Mesh(new THREE.BoxGeometry(0.7, 0.65, 0.75), bodyMat);
    head.position.set(0, 1.55, 1.35);
    head.castShadow = true;
    group.add(head);
    
    // Морда (верхняя часть)
    const snout = new THREE.Mesh(new THREE.BoxGeometry(0.55, 0.4, 0.8), bodyMat);
    snout.position.set(0, 1.58, 1.85);
    snout.castShadow = true;
    group.add(snout);
    
    // Нижняя челюсть
    const jaw = new THREE.Mesh(new THREE.BoxGeometry(0.53, 0.28, 0.75), bellyMat);
    jaw.position.set(0, 1.3, 1.82);
    jaw.castShadow = true;
    group.add(jaw);
    
    // Кончик морды
    const snoutTip = new THREE.Mesh(new THREE.BoxGeometry(0.4, 0.32, 0.45), new THREE.MeshStandardMaterial({ color: 0x3a2a1a }));
    snoutTip.position.set(0, 1.56, 2.25);
    snoutTip.castShadow = true;
    group.add(snoutTip);
    
    // ==================== ГЛАЗА ====================
    // Левый глаз
    const eyeL = new THREE.Mesh(new THREE.SphereGeometry(0.12, 24, 24), eyeMat);
    eyeL.position.set(-0.25, 1.68, 1.65);
    group.add(eyeL);
    
    // Правый глаз
    const eyeR = new THREE.Mesh(new THREE.SphereGeometry(0.12, 24, 24), eyeMat);
    eyeR.position.set(0.25, 1.68, 1.65);
    group.add(eyeR);
    
    // Зрачки
    const pupilMat = new THREE.MeshStandardMaterial({ color: 0x000000 });
    const pupilL = new THREE.Mesh(new THREE.SphereGeometry(0.06, 16, 16), pupilMat);
    pupilL.position.set(-0.25, 1.67, 1.77);
    group.add(pupilL);
    
    const pupilR = new THREE.Mesh(new THREE.SphereGeometry(0.06, 16, 16), pupilMat);
    pupilR.position.set(0.25, 1.67, 1.77);
    group.add(pupilR);
    
    // Блики
    const highlightMat = new THREE.MeshStandardMaterial({ color: 0xffffff });
    const highL = new THREE.Mesh(new THREE.SphereGeometry(0.035, 12, 12), highlightMat);
    highL.position.set(-0.29, 1.72, 1.78);
    group.add(highL);
    
    const highR = new THREE.Mesh(new THREE.SphereGeometry(0.035, 12, 12), highlightMat);
    highR.position.set(0.21, 1.72, 1.78);
    group.add(highR);
    
    // ==================== РОГА ====================
    // Левый рог
    const hornL = new THREE.Mesh(new THREE.ConeGeometry(0.13, 0.55, 8), hornMat);
    hornL.position.set(-0.32, 1.88, 1.45);
    hornL.rotation.z = -0.25;
    hornL.rotation.x = -0.15;
    hornL.castShadow = true;
    group.add(hornL);
    
    // Правый рог
    const hornR = new THREE.Mesh(new THREE.ConeGeometry(0.13, 0.55, 8), hornMat);
    hornR.position.set(0.32, 1.88, 1.45);
    hornR.rotation.z = 0.25;
    hornR.rotation.x = -0.15;
    hornR.castShadow = true;
    group.add(hornR);
    
    // Задний рог
    const hornBack = new THREE.Mesh(new THREE.ConeGeometry(0.1, 0.4, 8), hornMat);
    hornBack.position.set(0, 1.92, 1.2);
    hornBack.rotation.x = -0.35;
    hornBack.castShadow = true;
    group.add(hornBack);
    
    // ==================== КРЫЛЬЯ ====================
    // Левое крыло - плечевая кость
    const wingArmL = new THREE.Mesh(new THREE.BoxGeometry(0.15, 0.12, 1.1), wingMat);
    wingArmL.position.set(-0.85, 0.75, 0.45);
    wingArmL.rotation.z = -0.45;
    wingArmL.rotation.x = 0.15;
    wingArmL.castShadow = true;
    group.add(wingArmL);
    
    // Левое крыло - мембрана (сплюснутый куб)
    const membraneL = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.05, 1.4), wingMat);
    membraneL.position.set(-1.35, 0.68, 0.55);
    membraneL.rotation.z = -0.7;
    membraneL.rotation.x = 0.1;
    membraneL.scale.set(1, 1, 1.2);
    membraneL.castShadow = true;
    group.add(membraneL);
    
    // Дополнительная часть крыла
    const wingTipL = new THREE.Mesh(new THREE.BoxGeometry(0.1, 0.08, 0.9), wingMat);
    wingTipL.position.set(-1.75, 0.6, 0.65);
    wingTipL.rotation.z = -0.9;
    wingTipL.castShadow = true;
    group.add(wingTipL);
    
    // Правое крыло - плечевая кость
    const wingArmR = new THREE.Mesh(new THREE.BoxGeometry(0.15, 0.12, 1.1), wingMat);
    wingArmR.position.set(0.85, 0.75, 0.45);
    wingArmR.rotation.z = 0.45;
    wingArmR.rotation.x = 0.15;
    wingArmR.castShadow = true;
    group.add(wingArmR);
    
    // Правое крыло - мембрана
    const membraneR = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.05, 1.4), wingMat);
    membraneR.position.set(1.35, 0.68, 0.55);
    membraneR.rotation.z = 0.7;
    membraneR.rotation.x = 0.1;
    membraneR.scale.set(1, 1, 1.2);
    membraneR.castShadow = true;
    group.add(membraneR);
    
    // Дополнительная часть крыла
    const wingTipR = new THREE.Mesh(new THREE.BoxGeometry(0.1, 0.08, 0.9), wingMat);
    wingTipR.position.set(1.75, 0.6, 0.65);
    wingTipR.rotation.z = 0.9;
    wingTipR.castShadow = true;
    group.add(wingTipR);
    
    // ==================== НОГИ ====================
    // Левая передняя нога (бедро)
    const legLFArm = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.32, 0.45), bodyMat);
    legLFArm.position.set(-0.55, 0.25, 0.7);
    legLFArm.castShadow = true;
    group.add(legLFArm);
    
    // Левая передняя нога (голень)
    const legLFLower = new THREE.Mesh(new THREE.BoxGeometry(0.28, 0.45, 0.35), bodyMat);
    legLFLower.position.set(-0.62, -0.08, 0.78);
    legLFLower.castShadow = true;
    group.add(legLFLower);
    
    // Левая передняя лапа
    const pawLF = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.18, 0.4), bodyMat);
    pawLF.position.set(-0.68, -0.38, 0.85);
    pawLF.castShadow = true;
    group.add(pawLF);
    
    // Правая передняя нога
    const legRFArm = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.32, 0.45), bodyMat);
    legRFArm.position.set(0.55, 0.25, 0.7);
    legRFArm.castShadow = true;
    group.add(legRFArm);
    
    const legRFLower = new THREE.Mesh(new THREE.BoxGeometry(0.28, 0.45, 0.35), bodyMat);
    legRFLower.position.set(0.62, -0.08, 0.78);
    legRFLower.castShadow = true;
    group.add(legRFLower);
    
    const pawRF = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.18, 0.4), bodyMat);
    pawRF.position.set(0.68, -0.38, 0.85);
    pawRF.castShadow = true;
    group.add(pawRF);
    
    // Левая задняя нога
    const legLBArm = new THREE.Mesh(new THREE.BoxGeometry(0.38, 0.4, 0.55), bodyMat);
    legLBArm.position.set(-0.55, 0.12, -0.55);
    legLBArm.castShadow = true;
    group.add(legLBArm);
    
    const legLBLower = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.5, 0.45), bodyMat);
    legLBLower.position.set(-0.62, -0.22, -0.72);
    legLBLower.castShadow = true;
    group.add(legLBLower);
    
    const pawLB = new THREE.Mesh(new THREE.BoxGeometry(0.38, 0.2, 0.5), bodyMat);
    pawLB.position.set(-0.68, -0.55, -0.88);
    pawLB.castShadow = true;
    group.add(pawLB);
    
    // Правая задняя нога
    const legRBArm = new THREE.Mesh(new THREE.BoxGeometry(0.38, 0.4, 0.55), bodyMat);
    legRBArm.position.set(0.55, 0.12, -0.55);
    legRBArm.castShadow = true;
    group.add(legRBArm);
    
    const legRBLower = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.5, 0.45), bodyMat);
    legRBLower.position.set(0.62, -0.22, -0.72);
    legRBLower.castShadow = true;
    group.add(legRBLower);
    
    const pawRB = new THREE.Mesh(new THREE.BoxGeometry(0.38, 0.2, 0.5), bodyMat);
    pawRB.position.set(0.68, -0.55, -0.88);
    pawRB.castShadow = true;
    group.add(pawRB);
    
    // ==================== КОГТИ ====================
    const clawGeo = new THREE.BoxGeometry(0.08, 0.08, 0.16);
    const clawPositions = [
        // Передние лапы
        [-0.74, -0.42, 0.92], [-0.66, -0.42, 0.94], [-0.7, -0.44, 0.88],
        [0.74, -0.42, 0.92], [0.66, -0.42, 0.94], [0.7, -0.44, 0.88],
        // Задние лапы
        [-0.74, -0.6, -0.94], [-0.66, -0.6, -0.96], [-0.7, -0.62, -0.9],
        [0.74, -0.6, -0.94], [0.66, -0.6, -0.96], [0.7, -0.62, -0.9]
    ];
    
    clawPositions.forEach(pos => {
        const claw = new THREE.Mesh(clawGeo, clawMat);
        claw.position.set(pos[0], pos[1], pos[2]);
        claw.castShadow = true;
        group.add(claw);
    });
    
    // ==================== ХВОСТ ====================
    // Основание хвоста
    const tailBase = new THREE.Mesh(new THREE.BoxGeometry(0.45, 0.4, 0.75), bodyMat);
    tailBase.position.set(0, 0.05, -0.95);
    tailBase.castShadow = true;
    group.add(tailBase);
    
    // Средняя часть хвоста
    const tailMid = new THREE.Mesh(new THREE.BoxGeometry(0.38, 0.32, 0.85), bodyMat);
    tailMid.position.set(0, -0.05, -1.55);
    tailMid.castShadow = true;
    group.add(tailMid);
    
    // Дальняя часть хвоста
    const tailFar = new THREE.Mesh(new THREE.BoxGeometry(0.3, 0.26, 0.85), bodyMat);
    tailFar.position.set(0, -0.12, -2.15);
    tailFar.castShadow = true;
    group.add(tailFar);
    
    // Кончик хвоста
    const tailTip = new THREE.Mesh(new THREE.BoxGeometry(0.22, 0.2, 0.65), new THREE.MeshStandardMaterial({ color: 0x3a2a1a }));
    tailTip.position.set(0, -0.18, -2.7);
    tailTip.castShadow = true;
    group.add(tailTip);
    
    // ==================== ШИПЫ НА СПИНЕ ====================
    const spikeGeo = new THREE.BoxGeometry(0.12, 0.22, 0.12);
    const spikePositions = [
        [0, 0.72, -0.15], [0, 0.75, 0.05], [0, 0.74, 0.25], 
        [0, 0.7, 0.45], [0, 0.64, 0.62], [0, 0.55, 0.78],
        [0, 0.48, -0.45], [0, 0.42, -0.75], [0, 0.35, -1.05]
    ];
    
    spikePositions.forEach(pos => {
        const spike = new THREE.Mesh(spikeGeo, spikeMat);
        spike.position.set(pos[0], pos[1], pos[2]);
        spike.castShadow = true;
        group.add(spike);
    });
    
    // ==================== МЕЛКИЕ ДЕТАЛИ ====================
    // Ноздри
    const nostrilMat = new THREE.MeshStandardMaterial({ color: 0x332211 });
    const nostrilL = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.05, 0.08), nostrilMat);
    nostrilL.position.set(-0.12, 1.52, 2.32);
    group.add(nostrilL);
    
    const nostrilR = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.05, 0.08), nostrilMat);
    nostrilR.position.set(0.12, 1.52, 2.32);
    group.add(nostrilR);
    
    // "Брови"
    const browMat = new THREE.MeshStandardMaterial({ color: 0x3a2a1a });
    const browL = new THREE.Mesh(new THREE.BoxGeometry(0.22, 0.08, 0.12), browMat);
    browL.position.set(-0.32, 1.78, 1.58);
    browL.rotation.z = -0.1;
    browL.castShadow = true;
    group.add(browL);
    
    const browR = new THREE.Mesh(new THREE.BoxGeometry(0.22, 0.08, 0.12), browMat);
    browR.position.set(0.32, 1.78, 1.58);
    browR.rotation.z = 0.1;
    browR.castShadow = true;
    group.add(browR);
    
    // Чешуйки на спине (маленькие кубики)
    const scaleMat = new THREE.MeshStandardMaterial({ color: 0x5a3a2a });
    const scalePositions = [
        [-0.35, 0.52, 0.35], [0.35, 0.52, 0.35], [-0.3, 0.58, 0.12],
        [0.3, 0.58, 0.12], [-0.32, 0.48, -0.25], [0.32, 0.48, -0.25]
    ];
    
    scalePositions.forEach(pos => {
        const scale = new THREE.Mesh(new THREE.BoxGeometry(0.12, 0.05, 0.12), scaleMat);
        scale.position.set(pos[0], pos[1], pos[2]);
        scale.castShadow = true;
        group.add(scale);
    });
    
    return group;
}